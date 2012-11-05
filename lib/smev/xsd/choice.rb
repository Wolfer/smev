module Smev
	module XSD
		class Choice < ComplexType

			def parent; WSDL::XMLSchema::Choice; end

			def to_xml nss
				self.children.each{|child| return child.to_xml(nss) if child.valid? }
				raise SmevException.new("Invalid choice!")
			end

			def valid?
				check = false
				self.children.each{|child| check = true if child.valid? }
				#FIXME do choice validation
				check
			end

			def errors
				self.valid? ? {} : super 
			end

			def load_from_nokogiri noko
				check = false
				mb = []
				@children.each do |child| 
					begin
						child.load_from_nokogiri noko
						check = true
					rescue SmevException => e
						mb << e.to_s
					end
				end
				if check
					true
				else
					raise SmevException.new(mb.join(" OR "))
				end
			end

		end
	end
end