module Smev
	module XSD
		class Value

			attr_accessor :default
			attr_accessor :type
			
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
				return obj unless obj.type = type
				if type.is_a? WSDL::XMLSchema::SimpleType and restrict = type.restriction
					t = type
					t = t.restriction.base_type while t.base.namespace != ::XSD::Namespace
					obj.type = t.base
					obj.enumeration = restrict.enumeration || []
					obj.length = restrict.length
					obj.minlength = restrict.minlength
					obj.maxlength = restrict.maxlength
					obj.pattern = (restrict.pattern||[]).map{|reg| reg.to_s[7..-2] } # RegExp to_s and del (?-mix: )
				end
				obj.type = obj.type.name while not obj.type.is_a? String
				obj.default = default
				obj.set val
				yield(obj) if block_given?
				obj
			end	

			def self.build_from_hash hash
				obj = self.new
				if hash
					# obj.instance_eval "@value = '#{hash["value"]}'"
					obj.set hash["value"]
					obj.type = hash["type"]
					%w(enumeration length minlength maxlength pattern).each do |m|
						 obj.send("#{m}=", hash["restrictions"][m]) if hash["restrictions"][m].present?
					end if hash["restrictions"].present?
					obj.enumeration ||= []
				end
				yield(obj, hash) if block_given?
				obj
			end


			def set val
				@value = val
			end

			# def get; @value.present? ? @value.to_s : ( self.default || '' ); end
			def get; @value.nil? ? ( self.default || nil ) : @value.to_s ; end
			def to_s; @value.present? ? @value.to_s : ( self.default || '' ); end
			def inspect; "#<Value #{@value.inspect} >"; end

			def as_hash
				{ "type" => self.type }.tap do |hash| 
					hash["restrictions"] = {}
					%w(enumeration length minlength maxlength pattern).each do |m|
						hash["restrictions"][m] = self.send(m) if self.send(m).present?
					end
				end
				
			end

			def as_xsd
				return "" unless self.restricted?
				str = "<xs:simpleType>"
				str << "<xs:restriction base=\"#{self.type_with_namespace}\">"
				%w(length minLength maxLength).each do |m|
					 str << "<xs:#{m} value=\"#{self.send(m.downcase)}\"/>" if self.send(m.downcase)
				end
				%w(enumeration pattern).each do |m|
					#FIXME remove support pattern as string
					str << [*self.send(m)].map{|e| "<xs:#{m} value=\"#{e}\"/>" }.join
				end
				str << "</xs:restriction>"
				str << "</xs:simpleType>"
			end

			#TODO hardcore kostyl. wait namespace work
			def type_with_namespace
				"#{(self.type == "file" ? "tns" : "xs")}:#{self.type}"
			end

			def restricted?
				(length || minlength || maxlength || pattern || enumeration).present?
			end

			def blank?
				@value.blank?
			end

			def valid?
				raise ValueNilError.new("must not be nil") if @value.nil?
				check_enumeration
				check_length
				check_minlength
				check_maxlength
				check_pattern
				true
			end

			def fill_test
				return @value if @value.present?
				@value =  case self.type
				when "string"
					if self.enumeration.present?
						self.enumeration.first
					else
						val = ''
						val = regexp_to_str [*self.pattern].first if self.pattern.present?
						while self.minlength.present? and val.size < self.minlength.to_i
							val << "9"
						end
						while self.maxlength.present? and val.size > self.minlength.to_i
							val = val[0..-2]
						end
						if self.length.present?
							val << "9" while val.size < self.length.to_i
							val = val[0..-2] while val.size > self.length.to_i
						end
						val
					end			
				when "dateTime"
					Time.now.xmlschema
				else
					''
				end
			end

		private
			
			def check_enumeration
				unless !self.enumeration.present? or self.enumeration.include?(@value)
					raise ValueError.new(" must be in #{self.enumeration.inspect}")
				end
			end

			def check_length
				unless self.length.nil? or @value.to_s.size == self.length.to_i
					raise ValueError.new(" length must be: value == #{self.length}")
				end
			end

			def check_minlength
				unless self.minlength.nil? or @value.to_s.size >= self.minlength.to_i
					raise ValueError.new(" length must be: value > #{self.minlength}")
				end
			end

			def check_maxlength
				unless self.maxlength.nil? or @value.to_s.size <= self.maxlength.to_i
					raise ValueError.new(" length must be: value < #{self.maxlength}")
				end
			end

			def check_pattern
				if @pattern.present? and [*@pattern].select{|pattern| Regexp.new("^#{pattern}$") =~ @value.to_s }.blank?
					raise ValueError.new(" must be: value =~ %s" % [*@pattern].join(" or "))
				end
			end

			def regexp_to_str reg
				reg = reg.to_s.sub(/\(\?\-mix\:(.+)\)/,"\\1")
				reg.gsub! /\d-(\d)/, '\\1' # 0-9
				reg.gsub! /\w-(\w)/, '\\1' # A-Z
				reg.gsub! /\[([^\]])+\]/, '\\1' # [<any>]

				reg.gsub! /\\d/, '9' # \d
				reg.gsub! /\\w/, 'X' # \w

				while reg.match /(.)\{(\d+)[^\}]*\}/
				  reg.sub! /(.)\{(\d+)[^\}]*\}/, ($1 * $2.to_i)  # replace .{\d}
				end

				while reg.match /\([^\)]+\)/ # if skobka
				  while reg.match /\(([^\)\|]+)\|[^\)]+\)/
				    reg.gsub! /\(([^\)\|]+)\|[^\)]+\)/, '\\1' # replace (|)
				  end


				  while reg.match /\(([^\)\|]+)\)/
				    reg.gsub! /\(([^\)\|]+)\)/, '\\1' # replace ()
				  end
				end

				reg.gsub! /([^\\])\./, "\\1x"
				reg.gsub! /([\\])\./, "."

				reg
			end

		end

		class ValueError < SmevException
		end

		class ValueNilError < SmevException
		end

	end
end