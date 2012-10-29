module Smev
	module XSD
		class Any < Node

			attr_accessor :value
			attr_accessor :namespace


			def name
				"#any#"
			end

			#REWRITE
			def self.build_from_xsd xsd
				super(xsd) do |obj, xsd|
					obj.namespace = xsd.namespace
					obj.value = {}
				end
			end

			def self.allow_child 
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

			def as_xsd
				'<xs:any ' + super + '/>'
			end

			def to_ary
				[]
			end

		private
			def method_missing method, *argv, &block
				puts "[ERROR] #{self.class} not respond to '#{method}' method"
			end

		end
	end
end