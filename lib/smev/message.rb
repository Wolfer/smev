require 'builder'
module Smev

	class Message

		include Crypt::OpenSSL
	#  include Crypt::CryptoPro

		attr_reader :struct
		attr_reader :header_addition
		attr_accessor :namespaces
		attr_accessor :files

		 def self.gen_guid
			guid = Digest::MD5.hexdigest( Time.now.to_i.to_s )
			guid[20...20] = "-"
			guid[16...16] = "-"
			guid[12...12] = "-"
			guid[8...8] = "-"
			guid
		end
		
		def initialize value
			if value.is_a?(WSDL::Info)
				@struct = [*value].map{ |x| Smev::XSD.const_get(x.class.to_s.split("::").last).build_from_xsd x }
			else
				value = [value] unless value.is_a?(Array)
				@struct = [*value].map{ |x| Smev::XSD.const_get(x["type"].capitalize).build_from_hash x }
			end
			@errors = {}			
			self.files ||= []
		end

		###### Import Section

		def load_from_hash hash
			raise SmevException.new("Expect Hash, but given #{hash.class}") unless hash.is_a? Hash
			struct.each{ |s| s.load_from_hash hash[s.name].dup if hash.include? s.name }
			return true
		rescue SmevException => e
			puts "[ERROR] Loading from hash! #{e}"
			puts e.backtrace.first(5).join("\n")
			@errors["load_from_hash"] = e.to_s
			return false
		end

		def load_from_xml xml
			Nori.strip_namespaces = true
			Nori.convert_tags_to { |tag| tag.camelcase(:lower).to_sym }
			Nori.parser = :nokogiri
			
			doc = Nokogiri::XML::Document.parse xml
			verify doc if doc.search_child("wsse:Security").size > 0
			app_data = doc.search_child("Body").first
			struct.each{ |s| s.load_from_nokogiri app_data }
			return true
		rescue SmevException => e
			puts "[ERROR] Loading from xml! #{e}"
			puts e.backtrace.first(5).join("\n")
			@errors["load_from_xml"] = e.to_s
			return false
		end

		###### Child Section

		def valid?
			self.struct.each{|child| return false unless child.valid? }
			return true
		end

		def errors
			@errors.merge self.struct.inject({}){ |res, child| res[child.name] = child.errors if child.errors.present?; res}
		end

		def search_child name
			self.struct.map{|s| s.search_child name }.compact.flatten
		end

		def get_child name
			self.search_child(name).first
		end

		def fill_test
			self.struct.each &:fill_test
		end

		###### Export Section

		def to_xml sign = true
			raise SmevException.new("Smev::Message not valid!") unless self.valid?
			
			collect_namespaces
			# body = self.struct.map{|s| s.to_xml( self.namespaces ) }.join("\n")
			# view = ActionView::Base.new(Rails.root.join("lib/smev/template")).render(:template => "response", :locals => {:result => body, :namespaces => self.namespaces})
			result = self.struct.map{|s| s.to_xml( self.namespaces ) }.join("\n")
			xml = Builder::XmlMarkup.new
			eval File.read(File.dirname(__FILE__)+"/template/response.builder")
			doc = Nokogiri::XML::Document.parse xml.target.gsub(/\t/, '')
			doc = signature doc if sign
			doc.to_s
		end

		def as_hash
			self.struct.map{|child| child.as_hash }
		end

		def as_xsd tns = "rnd-soft.ws"
			# self.struct.map{|child| child.as_xsd }
			# txt = '<?xml version="1.0" encoding="UTF-8"?><xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" targetNamespace="'+tns+'" elementFormDefault="qualified">'
      txt = self.get_child("AppData").children.map(&:as_xsd).join
      # txt << '</xs:schema>'        
		end


		###### AppDocument Section

		def set_appdoc
			return nil unless have_appdoc?
			Zip::Archive.open('filename.zip', Zip::CREATE) do |ar|
				self.files.each do |f|
					ar.add_file(f) if File.exist? f
				end
			end
		end

		def get_appdoc
			return nil unless have_appdoc?
			tmpdir = Dir.mktmpdir
			data = Base64.decode64 bd.value.get
			Zip::Archive.open_buffer(data) do |ar|
				ar.each do |f|
					path = File.join( tmpdir, f.name )
					if f.directory?
						FileUtils.mkdir_p(path)
					else  
						buf = ''
						f.read{ |chunk| buf << chunk }
						File.write path, buf.force_encoding("UTF-8")
						self.files << path
					end
				end
			end

			tmpdir
		end

		def remove_appdoc
			if  md = self.search_child("MessageData").first
				md.children.delete_if{|child| child.name == "AppDocument" }
			end
		end

		def have_appdoc?
			bd = self.get_child("BinaryData") and bd.value.get.present?
		end

	private

		#FIXME deprecated
		def collect_namespaces
			self.namespaces ||= {}
			nss = struct.map( &:collect_namespaces ).flatten.uniq
			nss.each_with_index do |ns, i| 
				next if self.namespaces.values.include? ns
				name =  "xmlns:" + (ns.index("smev.gosuslugi.ru") ?  "smev" : "m#{i}")
				self.namespaces[name] = ns
			end

		end

	end

end

