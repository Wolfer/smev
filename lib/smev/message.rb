require 'builder'
require 'zipruby'
require 'fileutils'

module Smev

	class Message

		include Crypt::OpenSSL
	#  include Crypt::CryptoPro

		attr_reader :struct
		attr_reader :header_addition
		attr_accessor :namespaces
		attr_accessor :files
		attr_writer :attachment_schema

		 def self.gen_guid
			guid = Digest::MD5.hexdigest( Time.now.to_f.to_s )
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
			struct.each{ |s| s.load_from_hash hash }
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
			elements = doc.search_child("Body").first.children.find{|e| e.name != "text"}
			struct.each{ |s| s.load_from_nokogiri elements }
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

			if need_appdoc?
				set_appdoc
			else
				remove_appdoc 
			end
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

		def to_hash
			self.struct.inject({}) do |res,el| 
				if res.include? el.name
					if res[el.name].is_a? Array
						res[el.name] << el.to_hash
					else
						res[el.name] = [ res[el.name], el.to_hash[el.name] ]
					end
				else
					res.merge! el.to_hash
				end
				res
			end
		end

		def as_hash
			self.struct.map{|child| child.as_hash }
		end

		def as_xsd tns = "rnd-soft.ws"
      self.get_child("AppData").children.as_xsd
		end


		###### AppDocument Section
		def set_appdoc
			Dir.mktmpdir do |path|
				guid = self.class.gen_guid
				self.files.delete_if{|f| not File.exist? f }
				return false if self.files.blank?
				attachment_schema.children.recreate_child("AppliedDocument", self.files.size)
				attachment_schema.children.zip(self.files).each do |xsd, f|
					FileUtils.cp f, path
					xsd.load_from_hash "AppliedDocument" => {
								"Name" => File.basename(f), 
								"Type" => "", 
								"URL" => "./"
					}
				end
				File.write("#{path}/req_#{guid}.xml", attachment_schema.to_xml(attachment_schema.collect_namespaces))

				Zip::Archive.open("#{path}/req_#{guid}.zip", Zip::CREATE) do |ar|
					Dir.glob("#{path}/*").each do |f|
						ar.add_file(f)
					end
				end
				self.get_child("RequestCode").set guid if self.get_child("RequestCode")
				self.get_child("BinaryData").set Base64.encode64(File.read("#{path}/req_#{guid}.zip"))
			end
		end

		def get_appdoc dir
			return nil unless bd = self.get_child("BinaryData") and bd.get.present?
			raise SmevException.new("get_appdoc must get tmpdir as argument") unless File.directory? dir

			data = Base64.decode64 bd.value.get
			att_files = []
			Zip::Archive.open_buffer(data) do |ar|
				ar.each do |f|
					path = File.join( dir, f.name )
					if f.directory?
						FileUtils.mkdir_p(path)
					else  
						buf = ''
						f.read{ |chunk| buf << chunk }
						File.write path, buf.force_encoding("UTF-8")
						att_files << path
					end
				end
			end
			if req_xml = att_files.find{|af| af.match(/req_[^\.]+\.xml/) }
				attachment_schema.load_from_nokogiri Nokogiri::XML::Document.parse(File.read(req_xml)).children.first
				attachment_schema.search_child("AppliedDocument").each do |ad| 
					self.files << File.join(dir, ad.get_child("URL").get, ad.get_child("Name").get)
				end
			else
				raise SmevException.new("Not have req_<GUID>.xml")
			end

			dir
		end

		def remove_appdoc
			return false unless md = self.get_child("MessageData")
			md.children.delete_if{|child| child.name == "AppDocument" }
		end

		def need_appdoc?
			return false unless ad = self.get_child("AppDocument")
			@files.present? or ad.min_occurs > 0
		end

		def attachment_schema
			@attachment_schema ||= begin
				hash = {"name"=>"AppliedDocuments", "type"=>"element", "namespace"=>"http://rnd-soft.ru", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
					{"name"=>"AppliedDocument", "min_occurs"=>0, "max_occurs"=>999, "type"=>"element", "children"=>[{"name"=>"Smev::XSD::Sequence", "type"=>"sequence", "children"=>[
						{"name"=>"CodeDocument", "min_occurs"=>0, "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, 
						{"name"=>"Name", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, 
						{"name"=>"Number", "min_occurs"=>0, "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, 
						{"name"=>"URL", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, 
						{"name"=>"Type", "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}, 
						{"name"=>"DigestValue", "min_occurs"=>0, "type"=>"element", "value"=>{"type"=>"string", "restrictions"=>{}}}
					]}], "attributes" => [{"name"=>"ID", "type"=>"string", "restrictions"=>{"minlength"=>1, "maxlength"=>1000}}] }
				]}]}
				Smev::XSD::Element.build_from_hash hash
			end
		end


		def dup
			super.tap{|obj| obj.instance_eval{ struct = self.struct.map(&:dup) } }
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

