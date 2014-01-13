module Smev
	module XSD
		class Element < Node

			attr_accessor :name
			attr_accessor :namespace
			attr_accessor :attributes
			attr_accessor :value


			def self.build_from_xsd xsd, root_message = nil
				super do |obj, xsd|
					obj.name = xsd.name.name
					obj.namespace = xsd.name.namespace
					if xsd.complex_type
						obj.attributes = xsd.complex_type.attributes.map{|attr| Attribute.build_from_xsd attr }
						obj.children = child_factory xsd.complex_type.content_type, root_message
					end
					obj.value = Value.build_from_xsd( xsd.simple_type, xsd.default ) if obj.leaf?
				end
			end

			def self.build_from_hash hash, root_message = nil, ns = nil
				super do |obj, hash|
					obj.name = hash["name"]
					obj.namespace = hash["namespace"] || ns
					obj.value = Value.build_from_hash hash["value"] if obj.leaf?
					obj.attributes = hash["attributes"].map{|attr| Attribute.build_from_hash attr} if hash["attributes"].present?
					obj.children = obj.children.first if obj.children
				end
			end

			def can_occurs num
				if num.between? self.min_occurs, self.max_occurs
					true
				else
					raise SmevException.new("Expect that #{name} occurs #{self.min_occurs.to_i} - #{self.max_occurs}, but given #{num}")
				end
			end

			def element_name
				self.name
			end

			def attribute name
				self.attributes.find{|a| a.name == name } if self.attributes
			end

			def set value
				self.value.set value
			end

			def get
				self.value.get
			end

			def to_xml  nss
				raise SmevException.new("Not valid element #{self.name}") unless self.valid?(false)
				nss = {} unless nss.is_a? Hash
				ns = nss.key(self.namespace)
				ns = ns ? ns.split(':').last.to_s+":" : ''
				result = "<"+ns+self.name
				result << " "+self.attributes.select(&:valid?).join(" ") if self.attributes.present?

				content = if self.leaf?
					if txt = self.value.get
						txt.gsub("<", "&lt;").gsub( ">", "&gt;")
					end
				else
					"\n"+self.children.to_xml( nss )+"\n"
				end

				if content.to_s.strip.present?
					result << ">#{content}</#{ns}#{self.name}>"
				else
					if self.min_occurs.zero? and ( self.attributes.nil? or self.attributes.select{|a| a.present?}.blank? )
						result = ''
					else
						result << "/>"
					end
				end
						
				result 
			rescue SmevException => e
				if self.min_occurs.zero?
					''
				else
					raise e 
				end
			end

			def as_hash ns = nil
				super.tap do |hash| 
					hash["min_occurs"] = self.min_occurs if self.min_occurs and self.min_occurs != 1
					hash["max_occurs"] = self.max_occurs if self.max_occurs and self.max_occurs != 1
					hash["value"] = value.as_hash if self.leaf? and self.attributes.blank?
					hash["attributes"] = self.attributes.map{|attr| attr.as_hash} if self.attributes.present?
				end
			end

			def as_xsd
				str = '<xs:element name="' + self.name.to_s + '"'
				str << " minOccurs=\"#{self.min_occurs}\"" if self.min_occurs != 1
				str << " maxOccurs=\"#{self.max_occurs}\"" if self.max_occurs != 1
				if not self.leaf? or self.attributes.present?
					str << ">"
					str << "<xs:complexType>"
					str << self.children.as_xsd if self.children
					str << self.attributes.map(&:as_xsd).join if self.attributes.present?
					str << "</xs:complexType>"
					str << "</xs:element>"
				elsif self.value.restricted?
						str << ">"
						str << self.value.as_xsd
						str << "</xs:element>"
				else
					str << " type=\"#{self.value.type_with_namespace}\" />"
				end
				str
			end

			def to_hash short = true
				result = {}
				result["@attr"] = self.attributes.inject({}){| hash, attr |  hash[attr.name] = attr.get ; hash } if self.attributes.present?
				if self.leaf?
					if result.include?("@attr") 
						if ( val = self.value.get ).present?
							result["@value"] = val 
						end
					else
						return {} if short and self.value.get.nil?
						result = self.value.get
					end
				else
					result.merge! self.children.to_hash(short)
				end

				{ self.name => result }
			end

			def collect_namespaces
				result = [ self.namespace ]
				result << self.children.collect_namespaces.compact unless leaf?
				result
			end

			def search_child name
				result = []
				result << self if self.name == name
				result << self.children.search_child(name) unless self.leaf?
				result.flatten.compact
			end

			def get_child name
				self.search_child(name).first
			end

			def load_from_hash hash
				key, val = hash.is_a?(Hash) ? hash.to_a.first : [self.name, hash]
				unless key == self.name
					if min_occurs.zero?
						return false
					else
						raise SmevException.new("Wrong struct! Expect element #{self.name}, but given #{key}")
					end
				end
				if val.is_a? Hash
					if val.include? "@attr"
						val.fetch("@attr", {}).each { |k,v|   if  attr = self.attribute(k); attr.set(v); end }
					end
					if self.leaf?
						self.set(val.fetch("@value", nil) )
					else
						self.children.load_from_hash val 
					end
				else
					self.set(val) unless val.nil?
				end
			end

			def load_from_nokogiri noko
				unless noko.is_a? Nokogiri::XML::Element and noko.name == self.name
					if min_occurs.zero?
						return false
					else
						str = "Wrong struct! Expect element #{self.name}, but given "
						str << (noko.respond_to?("name") ?	noko.name : noko.inspect)
						raise SmevException.new(str)
					end
				end
				# puts ">#{self.name}"

				if xsi_type = noko.attributes["type"] and xsi_type.namespace.try(:href) == "http://www.w3.org/2001/XMLSchema-instance"
						ns_name = xsi_type.value.split(":")
						if root_message.wsdl.present? and ns = xsi_type.namespaces["xmlns:#{ns_name.first}"]
							if ct = root_message.wsdl.collect_complextypes[ ::XSD::QName.new(ns, ns_name.last) ]
								self.attributes = ct.attributes.map{|attr| Attribute.build_from_xsd attr }
								self.children = self.class.child_factory ct.content_type, root_message
							end
						end
				end

				noko.attributes.each do |k,v|
					next if k == "nil" # skip nillable element
					if attr = self.attribute(k)
						attr.set v.value
					end
				end

				if self.leaf?
					self.set noko.children.map{|t| t.text }.join
				else
					child_i = noko.children.select{|c| c.name != "text"}.each
					self.children.load_from_nokogiri child_i
					#get end of iterator if his not stop iterate
					if (not_approach = [].tap{|arr| loop{ arr << child_i.next.name } }).present?
						raise SmevException.new("Element #{self.name} don't include #{not_approach.inspect}")
					end
					
				end
				true
			end

			def self.allow_child 
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

			def valid? with_children = true
				@calc_errors = nil
				@errors = {}
				if self.attributes.present?
					self.attributes.each do |attr| 
						begin
							attr.valid?
						rescue ValueNilError => e
							@errors["@#{attr.name}"] = e.to_s if attr.required?
						rescue ValueError => e
							@errors["@#{attr.name}"] = "got '#{attr.get}', but expect then #{e.to_s}"
						end
					end
				end

				if self.leaf?
					begin
						self.value.valid? unless self.value.get.blank? and self.min_occurs.zero?
					rescue ValueNilError => e
						@errors["@value"] = e.to_s unless self.attributes.present?
					rescue ValueError => e
						@errors["@value"] = "got '#{self.value.get}', but expect then #{e.to_s}"
					end
				else
					return false if with_children and not self.children.valid?
				end			 
				@errors.empty?
			end

			def errors
				@calc_errors ||= begin
					errs = (@errors||{})
					if !self.leaf?
						errs.merge!(self.children.errors) if self.children.errors.present?
					end
					errs
				end
			end

			def fill_test
				self.attributes.each &:fill_test if self.attributes.present?
				if self.leaf?
					self.value.fill_test
				else
					self.children.fill_test
				end
			end

			def dup
				super.tap do |obj| 
					obj.attributes = self.attributes.map(&:dup) if self.attributes.present?
					obj.value = self.value.dup if self.leaf?
				end
			end

		end
	end
end