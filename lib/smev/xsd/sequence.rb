module Smev
	module XSD
		class Sequence < ComplexType

			def parent; WSDL::XMLSchema::Sequence; end

			def load_from_nokogiri noko
				@children.each{|child| child.load_from_nokogiri noko }
			end

		end
	end
end