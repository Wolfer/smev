module Smev
	module XSD
		class Choice < ComplexType

			def parent; WSDL::XMLSchema::Choice; end

			def to_xml nss
				self.children.each{|child| return child.to_xml(nss) if child.valid? rescue Exception }
				raise SmevException.new("Invalid choice!")
			end

			def valid?
				self.children.each{|child| return true if child.valid? rescue Exception }
				return false
				#FIXME do choice validation
			end

			def load_from_nokogiri noko
				@children.each{|child| child.load_from_nokogiri noko }
			end

		end
	end
end