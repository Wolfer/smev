module Smev
	module XSD
		class Attribute < Value

			attr_accessor :use
			attr_reader :name
			
			def initialize xsd
				super( (xsd.type || xsd.local_simpletype), xsd.default, xsd.fixed )
				self.use = xsd.use || "required"
				@name = xsd.name.name
			end	

			def required?
				self.use == "required"
			end

			def to_s
				if self.required? or @value.present?
					@name + '="'+ (@value.present? ? @value.to_s : ( self.default || '' )) +'"'
				else
					''
				end
			end

			def as_hash
				super.merge "name" => self.name, "use" => self.use
			end

			def inspect; "#<Attribute #{@name}=\"#{@value}\" >"; end

			def valid?
				return true if @value.blank? and not self.required?
				super
			end

		end
	end
end