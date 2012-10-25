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
	  
	  def initialize xsd
	    @struct = [*xsd].map{ |x| XSD::Element.new x }
	    self.files ||= []
	  end

	  def load_from_hash hash
	    struct.each{ |s| s.load_from_hash hash[s.name].dup if hash.include? s.name }
	  rescue SmevException => e
	    Rails.logger.error "[ERROR] Loading from hash! #{e}"
	    Rails.logger.error e.backtrace.first(5).join("\n")
	    puts "[ERROR] Loading from hash! #{e}"
	    puts e.backtrace.first(5).join("\n")
	  end

	  def load_from_xml xml
	    Nori.strip_namespaces = true
	    Nori.convert_tags_to { |tag| tag.camelcase(:lower).to_sym }
	    Nori.parser = :nokogiri
	    
	    doc = Nokogiri::XML::Document.parse xml
	    verify doc if doc.search_child("wsse:Security").size > 0
	    app_data = doc.search_child("Body").first
	    struct.each{ |s| s.load_from_nokogiri app_data }
	  rescue SmevException => e
	    Rails.logger.error "[ERROR] Loading from xml! #{e}"
	    Rails.logger.error e.backtrace.first(5).join("\n")
	    puts "[ERROR] Loading from xml! #{e}"
	    puts e.backtrace.first(5).join("\n")
	  end

	  def valid?
	    self.struct.each{|child| return false unless child.valid? }
	    return true
	  end

	  def to_xml
	    raise SmevException.new("Smev::Message not valid!") unless self.valid?
	    
	    collect_namespaces
	    body = self.struct.map{|s| s.to_xml( self.namespaces ) }.join("\n")
	    view = ActionView::Base.new(Rails.root.join("lib/smev/template")).render(:template => "response", :locals => {:result => body, :namespaces => self.namespaces})

	    doc = Nokogiri::XML::Document.parse view.gsub(/\t/,'')
	    doc = signature doc
	    doc.to_s
	  end

	  def search_child name
	    self.struct.map{|s| s.search_child name }.compact.flatten
	  end

	  def get_child name
	    self.search_child(name).first
	  end

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

