module Smev
	module XSD
		class All < ComplexType

			def parent; WSDL::XMLSchema::All; end

			def load_from_nokogiri nokogiris
				children_size = @children.group_by(&:name)
				nokogiri_size = nokogiris.group_by{|n| n.name}
				nokogiri_size.each do |name, nokos|
					next unless children_size[name] and children_size[name].size != nokos.size
					recreate_child name, nokos.size
				end


				req_name = @children.select{|child| not child.min_occurs.zero? }.map(&:name)
				if ( req_name -= nokogiris.map(&:name) ).present?
					raise SmevException.new("Required elements #{req_name.inspect} not found")
				end

				@children.group_by(&:name).each do |name, childrens|
					child = childrens.each
					nokogiri_size[name].each{|noko| iter.next.load_from_nokogiri noko }
				end

			end

		end
	end
end