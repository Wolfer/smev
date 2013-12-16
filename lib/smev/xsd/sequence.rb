module Smev
	module XSD
		class Sequence < ComplexType

			def parent; WSDL::XMLSchema::Sequence; end

			def min_occurs
				children.find{|child| not child.min_occurs.zero?}.present? ? 1 : 0
			end

			def load_from_nokogiri noko_i, noko = nil
				# puts "S #{noko_i.drop(0).map(&:name).inspect}"
				# puts "c #{@children.map(&:name).inspect}"
				children_size = @children.group_by(&:name)
				noko_i.drop(0).group_by{|n| n.name}.each do |name, nokos|
					next unless children_size[name] and children_size[name].size != nokos.size
					children_size[name].first.can_occurs nokos.size
					recreate_child name, nokos.size
				end

				noko ||= noko_i.next
				check_tail = false
				children_names = @children.map(&:element_name).flatten
				@children.each_with_index do |child, i|
					# puts "beg #{child.name} #{check_tail}"
					if check_tail
						raise SmevException.new("Expect #{child.name}, but nothing given") unless child.min_occurs.zero?
						next
					end
					begin
						if child.is_a?(Element)
							if noko.respond_to?(:name) and not children_names.include?(noko.name.to_s)
								raise SmevException.new("Element #{noko.name.to_s} not expect here!")
							end
							begin
								noko = noko_i.next if child.load_from_nokogiri noko
							rescue SmevException => e
								# puts ">>#{child.name} #{e.to_s}"
								next if child.min_occurs.zero?
								raise SmevException.new(e.to_s)				
							end
						else
							noko = child.load_from_nokogiri( noko_i, noko)
						end
					rescue StopIteration => e
						# puts "--#{noko_i.drop(0).map(&:name).inspect}"
						check_tail = true
					end
				end
				noko unless check_tail
			rescue StopIteration => e
				text = "Except that Sequence have element #{@children.map(&:name).inspect}"
				raise SmevException.new(text) unless self.min_occurs.zero?
			end # def

		end 
	end
end