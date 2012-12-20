module Smev
	module XSD
		class Attribute < Value

			attr_accessor :use
			attr_reader :name
			
			def self.build_from_xsd xsd
				super( (xsd.simple_type), xsd.default, xsd.fixed ) do |obj|
					obj.use = xsd.use || "required"
					obj.instance_eval "@name = '#{xsd.name.name}'"
					obj
				end
			end	

			def self.build_from_hash hash
				super hash do |obj, hash|
					obj.instance_eval "@name = '#{hash["name"]}'"
					obj.use = hash["use"]
				end
			end

			def required?
				self.use == "required"
			end

			def to_s
				if self.required? or @value.present?
					@name + "=\"#{(@value.present? ? @value : ( self.default || '' )).gsub('"','&quot;')}\""
				else
					''
				end
			end

			def as_hash
				super.merge "name" => self.name, "use" => self.use
			end

			def as_xsd
				str = '<xs:attribute name="' + self.name.to_s + '" '
				str << ' use="required" ' if self.required?
				if self.restricted?
					str << ">"
					str << super
					str << "</xs:attribute>"
				else
					str << "type=\"xs:#{self.type}\"/>"
				end
				str 
			end

			def inspect; "#<Attribute #{@name}=\"#{@value}\" >"; end

			def valid?
				return true if @value.blank? and not self.required?
				super
			end

		end
	end
end