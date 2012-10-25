module Smev
	module XSD
		class All < ComplexType

			def parent; WSDL::XMLSchema::All; end

			def load_from_nokogiri noko
				@children.each{|child| child.load_from_nokogiri noko }
			end
		end
	end
end