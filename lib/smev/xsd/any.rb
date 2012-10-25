module Smev
	module XSD
		class Any < Node

			attr_accessor :value
			attr_accessor :namespace


			#REWRITE
			def initialize xsd
				raise SmevException.new("[ERROR] Expect WSDL::XMLSchema::Any, but given #{xsd.class}\n") unless xsd.is_a? WSDL::XMLSchema::Any
				self.namespace = xsd.namespace
				self.value = {}
			end	

			def allow_child 
				{ 
					WSDL::XMLSchema::Choice => Choice, 
					WSDL::XMLSchema::Sequence => Sequence, 
					WSDL::XMLSchema::Element => Element 
				}
			end

			def collect_namespaces
		#		self.namespace
				nil
			end


			def valid?
				true
			end

			def to_hash
				self.value || {}
			end

			def to_xml nss
				ns = nss.index(self.namespace)
				ns = ns ? "#{ns.split(":").last}:" : ''
				Features::build_xml do |xml|
					hash_to_xml = lambda do |hash|
						hash.each do |k,v|
							if v.is_a? Hash
								xml.tag! "#{ns}#{k}" do
									hash_to_xml v
								end
							else
								xml.tag! "#{ns}#{k}", v.to_s
							end
						end
					end

					hash_to_xml[ self.value ]
				end

			end
		end
	end
end