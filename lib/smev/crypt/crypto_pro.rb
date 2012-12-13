require 'base64'
require 'tempfile'

module Smev
  module Crypt
    module CryptoPro

      def signature doc
        xml4sign = Features::write_tmp doc
        signed_xml = Features::write_tmp ''
        if Kernel.system(sign_path + "sign_xml.exe sign #{xml4sign.path} #{signed_xml.path} TEST 111111")
          doc = File.read signed_xml.path 
        else
          raise SignatureError.new("Signature failed")
        end
      end

      def verify doc
        xml2verify = Features::write_tmp doc
        Kernel.system(sign_path + "sign_xml.exe verify #{xml2verify.path}")
      end

      def sign_path
        File.join File.dirname(__FILE__), 'bin', ''
      end


    end
  end
end