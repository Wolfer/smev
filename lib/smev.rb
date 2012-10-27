require 'bundler/setup'

require 'nokogiri'
require 'nori'

require 'ext/object'

require 'smev/extensions/wsdl'
require 'smev/extensions/nokogiri'
require 'smev/exception'

require 'smev/crypt/error'
require 'smev/crypt/openssl_gost'
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
