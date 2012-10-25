module Smev
	module XSD
		class Element < Node

			attr_accessor :name
			attr_accessor :namespace
			attr_accessor :attributes
			attr_accessor :value


			def initialize xsd
				raise SmevException.new("[ERROR] Expect WSDL::XMLSchema::Element, but given #{xsd.class}\n") unless xsd.is_a? WSDL::XMLSchema::Element
				self.name = xsd.name.name
				self.namespace = xsd.name.namespace
				self.min_occurs = xsd.minoccurs
				self.max_occurs = xsd.maxoccurs
				if xsd.complex_type
					self.attributes = xsd.complex_type.attributes.map{|attr| Attribute.new attr }
					self.children = child_factory xsd.complex_type.content_type
				end
				self.value = Value.new( xsd.simple_type, xsd.default ) if self.leaf?
			end	

			def attribute name
				self.attributes.find{|a| a.name == name }
			end

			def to_xml  nss
				nss = {} unless nss.is_a? Hash
				ns = nss.key(self.namespace)
				ns = ns ? ns.split(':').last.to_s+":" : ''
				result = "<"+ns+self.name
				result << " "+self.attributes.join(" ") if self.attributes.present?

				content = self.leaf? ? self.value.get : "\n"+self.children.to_xml( nss )+"\n"

				if content.strip.present?
					result << ">#{content}</#{ns}#{self.name}>"
				else
					if self.min_occurs == 0 and ( self.attributes.nil? or self.attributes.select{|a| a.present?}.blank? )
						result = ''
					else
						result << "/>"
					end
				end
						
				result 
			end

			def to_hash
				result = {}
				result["@attr"] = self.attributes.inject({}){| hash, attr |  hash[attr.name] = attr.get ; hash } if self.attributes.present?
				if self.leaf?
					if result.include?("@attr") 
						if ( val = self.value.get ).present?
							result["@value"] = val 
						end
					else
						result = self.value.get
					end
				else
					self.children.each do |child| 
						hash = child.to_hash
						if child.respond_to? "name" and result.include? child.name 
							if result[child.name].is_a? Array
								result[child.name] << hash.delete(child.name)
							else
								result[child.name] = [ result[child.name], hash.delete(child.name)]
							end
						else
							result.merge! hash
						end
					end 
				end

				{ self.name => result }
			end

			def collect_namespaces
				result = [ self.namespace ]
				result << self.children.map(&:collect_namespaces).compact unless leaf?
				result
			end

			def search_child name
				finder = lambda do |elem|
					result = []
					if elem.is_a? Element 
						result << elem if elem.name == name
						result << elem.children.map{|child| finder[child] } unless elem.leaf?
					else
						result << elem.children.map{|child| finder[child] } if elem.children
					end
					result
				end
				finder[self].flatten
			end

			def get_child name
				self.search_child(name).first
			end

			def load_from_hash hash
				if hash.is_a? Hash
					hash.fetch("@attr", {}).each { |k,v|   if  attr = self.attributes.find{|a| a.name == k}; attr.set(v); end }
					if self.leaf?
						self.value.set(hash.fetch("@value", nil) )
					else
						self.children.load_from_hash hash 
					end
				else
					self.value.set(hash) unless hash.nil?
				end
			end

			def load_from_nokogiri noko
				return false unless noko.is_a? Nokogiri::XML::Element and this_noko = noko.children.find{|c| c.name == self.name }
				this_noko.attributes.each do |k,v|
					next if k == "nil" # skip nillable element
					if attr = self.attributes.find{|a| a.name == k}
						attr.set v.value
					end
				end

				if self.leaf?#this_noko.children.group_by{|c| c.class}[Nokogiri::XML::Element].present?
					self.value.set this_noko.children.map{|t| t.text }.join
				else
					self.children.load_from_nokogiri this_noko
				end
			end

			def allow_child 
				{ 
					WSDL::XMLSchema::Choice => Choice, 
					WSDL::XMLSchema::Sequence => Sequence,
					WSDL::XMLSchema::All => All
				}
			end

			def clone
				new_obj = super
				new_obj.value = self.value.clone if self.leaf?
				if self.attributes.present?
					new_obj.attributes = self.attributes.map &:clone
				end
				
				new_obj
			end

			def valid?
				if self.attributes.present?
					self.attributes.each do |attr| 
						begin
							attr.valid?
						rescue ValueError => e
							raise ArgumentError.new("\"#{self.name}\" @#{attr.name} #{e.to_s}")
						end
					end
				end

				begin
					self.leaf? ? self.value.valid? : self.children.valid?
				rescue ValueError => e
					raise ArgumentError.new("\"#{self.name}\" #{e.to_s}")
				end
			end

			def fill_test
				if self.leaf?
					self.value.fill_test
				else
					self.children.each{|child| child.fill_test } 
				end
			end

		end
	end
end