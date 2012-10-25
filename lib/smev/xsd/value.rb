module Smev
	module XSD
		class Value

			attr_accessor :type
			attr_accessor :default
			
			attr_accessor :length
			attr_accessor :minlength
			attr_accessor :maxlength
			attr_accessor :pattern
			attr_accessor :enumeration
			attr_accessor :whitespace
			attr_accessor :maxinclusive
			attr_accessor :maxexlusive
			attr_accessor :minexlusive
			attr_accessor :mininclusive
			attr_accessor :totaldigits
			attr_accessor :fractiondigits
			

			def initialize type, default = nil, val = nil
				self.type = type
				if self.type.is_a? WSDL::XMLSchema::SimpleType and restrict = self.type.restriction
					self.enumeration = restrict.enumeration || []
					self.length = restrict.length
					self.minlength = restrict.minlength
					self.maxlength = restrict.maxlength
					self.pattern = restrict.pattern
				end
				self.default = default
				@value = val
			end	

			def set val
				@value = val
			end

			def get; @value.present? ? @value.to_s : ( self.default || '' ); end
			def to_s; @value.present? ? @value.to_s : ( self.default || '' ); end
			def inspect; "#<Value \"#{@value}\" >"; end

			def blank?
				@value.blank?
			end

			def valid?
				check_enumeration
				check_length
				check_minlength
				check_maxlength
				check_pattern
				true		
			end

			def fill_test
				@value =  if self.enumeration.present?
					self.enumeration.first
				elsif self.length
					"9" * self.length
				elsif self.minlength
					"9" * self.minlength
				elsif self.maxlength
					"9" * self.maxlength
				end			
			end

		private
			
			def check_enumeration
				unless !self.enumeration.present? or self.enumeration.include?(@value)
					raise ValueError.new(" must be in #{self.enumeration.inspect}")
				end
			end

			def check_length
				unless self.length.nil? or @value.to_s.size == self.length
					raise ValueError.new(" length must be: value == #{self.length}")
				end
			end

			def check_minlength
				unless self.minlength.nil? or @value.to_s.size >= self.minlength
					raise ValueError.new(" length must be: value > #{self.minlength}")
				end
			end

			def check_maxlength
				unless self.maxlength.nil? or @value.to_s.size <= self.maxlength
					raise ValueError.new(" length must be: value < #{self.maxlength}")
				end
			end

			def check_pattern
				unless self.pattern.nil? or self.pattern =~ @value.to_s
					raise ValueError.new(" must be: value =~ #{self.pattern.inspect}")
				end
			end


		end

		class ValueError < SmevException
		end

	end
end