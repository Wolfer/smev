require 'bundler/setup'

require 'nokogiri'
require 'nori'
require 'mime/types'
require 'httpi'

require 'smev/exception'

require 'ext/object'
require 'ext/features'
require 'ext/wsdl'
require 'ext/nokogiri'
require 'xsd/xmlparser/nokogiri'

require 'smev/crypt/error'
require 'smev/crypt/openssl_gost'
require 'smev/crypt/win_openssl_gost'
require 'smev/crypt/crypto_pro'

require 'smev/xsd/node'
require 'smev/xsd/value'
require 'smev/xsd/complex_type'
require 'smev/xsd/attribute'
require 'smev/xsd/all'
require 'smev/xsd/group'
require 'smev/xsd/sequence'
require 'smev/xsd/any'
require 'smev/xsd/choice'
require 'smev/xsd/element'

require 'smev/message'
require 'smev/request'
require 'smev/downloader'
require 'zip'

module Smev
end

NAMESPACES = {
	"soap" => "http://schemas.xmlsoap.org/soap/envelope/",
	"wsse" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
	"wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd",
	"ds" => "http://www.w3.org/2000/09/xmldsig#",
	"ws" => "http://188.127.229.126:7783/wsdl",
	"message" => "http://188.127.229.126:7783/schema/message",
	"smev" => "http://smev.gosuslugi.ru/rev120315",
	"smev_2_4" => "http://smev.gosuslugi.ru/rev111111",
	"smev_2_3" => "http://smev.gosuslugi.ru/rev110801"
}

PRIVATEKEY = File.join( File.dirname(__FILE__), "keys/seckey.pem")
CERTIFICATE = File.join( File.dirname(__FILE__), "keys/cert.pem")
Zip.setup do |c|
  c.on_exists_proc = true
  c.continue_on_exists_proc = true
  c.unicode_names = true
end
module Nokogiri
	module XML
		class ParseOptions
			remove_const(:DEFAULT_XML)
			DEFAULT_XML = RECOVER | NONET | HUGE
		end
	end
end