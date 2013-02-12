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

      def signature xml, actor = "http://smev.gosuslugi.ru/actors/smev"
        doc = Nokogiri::XML::Document.parse xml

        sig_xml = eval(File.read(File.dirname(__FILE__)+"/../template/signature.builder"))
        security_with_header = Nokogiri::XML::Document.parse(sig_xml).children.first
        security = security_with_header.search_child("Security", NAMESPACES['wsse']).first
        
        security.search_child("BinarySecurityToken", NAMESPACES['wsse']).first.children = File.read(get_certificate).gsub(/\-{2,}[^\-]+\-{2,}/,'').gsub(/\n\n+/, "\n")
        #digest
        security.search_child("DigestValue", NAMESPACES['ds']).first.children = digest doc.search_child("Body", NAMESPACES['soap']).first
        #signature
        sig_value =  calculate_signature( security.search_child("SignedInfo", NAMESPACES['ds']).first.canonicalize_excl )
        security.search_child("SignatureValue", NAMESPACES['ds']).first.children = sig_value

        if header = doc.search_child("Header", NAMESPACES['soap']).first
          header << security
        else
          doc.search_child("Body", NAMESPACES['soap']).first.add_previous_sibling security_with_header
        end
        doc.search_child("Envelope", NAMESPACES['soap']).first.add_namespace("wsse", NAMESPACES['wsse']) unless doc.namespaces.values.include? NAMESPACES['wsse']

        doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML )
      end

      def calculate_signature sig_info
        (Base64.encode64 Features::call_shell("openssl dgst -engine gost -sign #{get_private_key}", sig_info) ).strip
      end

      def verify xml
        doc = Nokogiri::XML::Document.parse xml
        doc.search_child("Security", NAMESPACES['wsse']).each do |security|
          next unless security["actor"] == "http://smev.gosuslugi.ru/actors/smev"
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
        if text = doc.css('*:regex("Id", "'+( ref["URI"].tr('#', '')) +'")', XPathFinder.new).first
          raise SignatureError.new("Wrong digest value") unless digest(text) == ref.search_child("DigestValue", NAMESPACES['ds']).first.children.to_s.strip
        else
          raise SignatureError.new("Not found signed partial!")
        end
      end

      def verify_signature security
        certificate = "-----BEGIN CERTIFICATE-----\n"
        certificate << Base64.encode64(Base64.decode64(security.search_child("BinarySecurityToken", NAMESPACES['wsse']).first.children.to_s.strip))
        certificate << "-----END CERTIFICATE-----"

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