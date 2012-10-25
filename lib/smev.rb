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