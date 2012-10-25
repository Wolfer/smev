module Smev
	module XSD
		class Group < ComplexType

			def parent; WSDL::XMLSchema::Group; end

			def load_from_nokogiri noko
				@children.each{|child| child.load_from_nokogiri noko }
			end

		end
	end
end