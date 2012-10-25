require 'base64'
require 'tempfile'

#PRIVATEKEY = Rails.root.join "keys/seckey.pem"
#CERTIFICATE = Rails.root.join "keys/cert.pem"

module Smev
  module Crypt
    module OpenSSL

      def signature doc
        security = doc.search_child("Security", NAMESPACES['wsse']).first
        security.search_child("BinarySecurityToken", NAMESPACES['wsse']).first.children = File.read(CERTIFICATE).gsub(/\-{2,}[^\-]+\-{2,}/,'').gsub(/\n\n+/, "\n")
        #digest
        security.search_child("DigestValue", NAMESPACES['ds']).first.children = digest doc.search_child("Body", NAMESPACES['soap']).first
        #signature
        sig_value =  calculate_signature( security.search_child("SignedInfo", NAMESPACES['ds']).first.canonicalize_excl )
        security.search_child("SignatureValue", NAMESPACES['ds']).first.children = sig_value
        doc
      end

      def calculate_signature sig_info
        (Base64.encode64 Features::call_shell("openssl dgst -engine gost -sign #{PRIVATEKEY}", sig_info) ).strip
      end

      def verify doc
        doc.search_child("Security", NAMESPACES['wsse']).each do |security|
          next unless security["actor"] == "http://smev.gosuslugi.ru/actors/smev"
          begin
            # verify digest value
            security.search_child("Reference", NAMESPACES['ds']).each { |ref|  check_digest doc, ref } 
            # check signature
            verify_signature security
          rescue SignatureError => e
            @last_error = e
            return false
          end
        end
        return true
      end

      def digest text
        calculate_hash = Features::call_shell('openssl dgst -engine gost -md_gost94 -binary', ( text.is_a?(String) ? text : text.canonicalize_excl ) )
        return (Base64.encode64 calculate_hash).strip
      end

      def check_digest doc, ref
        if text = doc.search_child('*[regex(., "Id", "'+( ref["URI"].tr('#', '')) +'")]', XPathFinder.new).first
          raise SignatureError.new("Wrong hash content") unless digest(text) == ref.search_child("DigestValue", NAMESPACES['ds']).children.to_s.strip
        else
          raise SignatureError.new("Not found signed partial!")
        end
      end

      def verify_signature security
        certificate = "-----BEGIN CERTIFICATE-----\n"
        certificate << security.search_child("BinarySecurityToken", NAMESPACES['wsse']).children.to_s.strip
        certificate << "\n-----END CERTIFICATE-----"

        public_key_file = Features::write_tmp Features::call_shell('openssl x509 -engine gost -pubkey -noout', certificate)
        signature_file = Features::write_tmp Base64.decode64(security.search_child("SignatureValue", NAMESPACES['ds']).children.to_s.strip)
        sig_info = security.search_child("SignedInfo", NAMESPACES['ds']).first.canonicalize_excl
        raise SignatureError.new("Wrong signature!") unless /OK/ =~ Features::call_shell( 'openssl dgst -engine gost -verify '+public_key_file.path+' -signature '+signature_file.path, sig_info )
      ensure
        public_key_file.unlink
        signature_file.unlink   
      end


    end
  end
end