require 'base64'
require 'tempfile'


module Smev
  module Crypt
    module OpenSSL

      def self.included base
        base.class_eval do
          attr_accessor :certificate, :private_key, :certificate_file, :private_key_file
        end
      end

      def get_certificate; @certificate || CERTIFICATE; end
      def get_private_key; @private_key || PRIVATEKEY; end
      def get_certificate_file; @certificate_file || get_certificate; end
      def get_private_key_file; @private_key_file || get_private_key; end
      def get_signature_template exists_nss = []
        nss = {}
        %w(soap wsse wsu ds).each do |ns|
          nss["xmlns:#{ns}"] = NAMESPACES[ns] unless exists_nss.include?(NAMESPACES[ns])
        end
        eval(File.read(File.dirname(__FILE__)+"/../template/signature.builder"))
      end

      def signature doc, actor = "http://smev.gosuslugi.ru/actors/smev"
        doc = Nokogiri::XML::Document.parse(doc) unless doc.is_a? Nokogiri::XML::Document
        envel = doc.search_child("Envelope", NAMESPACES['soap']).first
        body = envel.search_child("Body", NAMESPACES['soap']).first
        header = envel.search_child("Header", NAMESPACES['soap']).first
        used_prefixes = %w(soap wsse wsu ds)

        doc_nss = doc.collect_namespaces
        doc_nss.delete("xmlns")
        prefixes = used_prefixes.inject({}) do |res, name|
            res[name] = name
            doc_nss.find do |p, n|
              res[name] = p.gsub('xmlns:', '') if n == NAMESPACES[name]
            end
            res
          end

        # Add Header if not exist
        unless header
          header = envel.parse("<#{prefixes['soap']}:Header></#{prefixes['soap']}:Header>").first
          doc.search_child("Body", NAMESPACES['soap']).first.add_previous_sibling header
        end

        # Find namespace that not set in header scope
        visible_nss = header.namespace_scopes
        exists_nss = []
        %w(wsse wsu ds).each do |name|
          exists_nss << NAMESPACES[name] if visible_nss.find{|n| n.href == NAMESPACES[name] }
        end

        # Set right prefixes
        sig_tmpl = get_signature_template(exists_nss)
        used_prefixes.each do |name|
          sig_tmpl.gsub!("--#{name.upcase}--", prefixes[name])
        end
        
        security = header.parse(sig_tmpl).first
        header << security

        id = if id_attr = body.attribute_with_ns("Id", NAMESPACES["wsu"])
            id_attr.content
          else
            body.set_attribute("#{prefixes['wsu']}:Id", "body")
          end

        ref = security.search_child("Reference", NAMESPACES['ds']).first
        ref.attribute("URI").content = "##{id}"

        security.search_child("BinarySecurityToken", NAMESPACES['wsse']).first.children = File.read(get_certificate).gsub(/\-{2,}[^\-]+\-{2,}/,'').gsub(/\n\n+/, "\n")
        #digest
        security.search_child("DigestValue", NAMESPACES['ds']).first.children = digest(body)
        #signature
        sig_value =  calculate_signature( security.search_child("SignedInfo", NAMESPACES['ds']).first.canonicalize_excl )
        security.search_child("SignatureValue", NAMESPACES['ds']).first.children = sig_value


        unless doc.namespaces.values.include? NAMESPACES['wsse']
          doc.search_child("Envelope", NAMESPACES['soap']).first.add_namespace("wsse", NAMESPACES['wsse']) 
        end

        doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML )
      end

      def calculate_signature sig_info
        (Base64.encode64 Features::call_shell("openssl dgst -engine gost -sign #{get_private_key}", sig_info) ).strip
      end

      def verify doc
        doc = Nokogiri::XML::Document.parse(doc) unless doc.is_a? Nokogiri::XML::Document
        doc.search_child("Security", NAMESPACES['wsse']).each do |security|
          actor = security.attribute("actor")
          next unless actor and actor.value == "http://smev.gosuslugi.ru/actors/smev"
          # verify digest value
          security.search_child("Reference", NAMESPACES['ds']).each { |ref|  check_digest doc, ref } 
          # check signature
          verify_signature security
        end
        return true
      end

      def digest text
        calculate_hash = Features::call_shell('openssl dgst -engine gost -md_gost94 -binary', ( text.is_a?(String) ? text : text.canonicalize_excl ) )
        return (Base64.encode64 calculate_hash).strip
      end

      def check_digest doc, ref
        if text = doc.css('*:regex("Id", "'+( ref.attribute("URI").value.tr('#', '')) +'")', XPathFinder.new).first
          raise SignatureError.new("Wrong digest value") unless digest(text) == ref.search_child("DigestValue", NAMESPACES['ds']).first.children.to_s.strip
        else
          raise SignatureError.new("Not found signed partial!")
        end
      end

      def verify_signature security
        certificate = "-----BEGIN CERTIFICATE-----\n"
        certificate << Base64.encode64(Base64.decode64(security.search_child("BinarySecurityToken", NAMESPACES['wsse']).first.children.to_s.strip))
        certificate << "-----END CERTIFICATE-----"
        # OpenSSL::X509::Certificate.new(TEXT).issuer.to_s(OpenSSL::X509::Name::ONELINE ^ 4)


        public_key_file = Features::write_tmp Features::call_shell('openssl x509 -engine gost -pubkey -noout', certificate)
        signature_file = Features::write_tmp Base64.decode64(security.search_child("SignatureValue", NAMESPACES['ds']).first.children.to_s.strip)

        sig_info = security.search_child("SignedInfo", NAMESPACES['ds']).first.canonicalize_excl
        raise SignatureError.new("Wrong signature!") unless /OK/ =~ Features::call_shell( 'openssl dgst -engine gost -verify '+public_key_file.path+' -signature '+signature_file.path, sig_info )
      ensure
        public_key_file.unlink
        signature_file.unlink   
      end

      def sign_file file
        Features::call_shell( "openssl smime -sign -engine gost -gost89  -inkey #{get_private_key_file} -signer #{get_certificate_file} -in #{file} -out #{file}.sig -outform DER -binary", '' )
      end

      def verify_file file
        /successful/ =~ Features::call_shell( "openssl smime -verify -engine gost -noverify -inform DER -in #{file}.sig -content #{file}", '')
      end

    end
  end
end