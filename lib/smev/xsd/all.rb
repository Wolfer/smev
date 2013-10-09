module Smev
	module XSD
		class All < ComplexType

			def parent; WSDL::XMLSchema::All; end

			def load_from_nokogiri noko_iter
				children_size = @children.group_by(&:name)
				nokogiri_grouped = noko_iter.group_by{|n| n.name}
				nokogiri_grouped.each do |name, nokos|
					next unless children_size[name] and children_size[name].size != nokos.size
					recreate_child name, nokos.size
				end
				req_name = @children.select{|child| not child.min_occurs.zero? }.map(&:name)

				noko ||= noko_iter.next
				all_child = @children.dup
				loop do
					if child = all_child.find{|c| c.name == noko.name }
						child.load_from_nokogiri noko
						all_child.delete child
					else
						raise SmevException.new("Unexpect element #{noko.name} in input xml")
					end
					noko = noko_iter.next
				end

				if (req_names = all_child.select{|child| not child.min_occurs.zero? }.map(&:name)).present?
					raise SmevException.new("Expect #{req_names} in <all>")
				end

			end

		end
	end
end