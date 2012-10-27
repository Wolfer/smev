module Smev
	module XSD
		class Value

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
			

			def self.build_from_xsd type, default = nil, val = nil
				obj = self.new
				if type.is_a? WSDL::XMLSchema::SimpleType and restrict = type.restriction
					obj.enumeration = restrict.enumeration || []
					obj.length = restrict.length
					obj.minlength = restrict.minlength
					obj.maxlength = restrict.maxlength
					obj.pattern = restrict.pattern
				end
				obj.default = default
				obj.set val
				obj
			end	

			def set val
				@value = val
			end

			def get; @value.present? ? @value.to_s : ( self.default || '' ); end
			def to_s; @value.present? ? @value.to_s : ( self.default || '' ); end
			def inspect; "#<Value \"#{@value}\" >"; end

			def as_hash
				{ "value" => self.get }.tap do |hash| 
					hash["restriction"] = {}
					%w(enumeration length minlength maxlength pattern).each do |m|
						hash["restriction"][m] = self.send(m) if self.send(m).present?
					end
				end
				
			end

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