module Smev
	module XSD
		class Sequence < ComplexType

			def parent; WSDL::XMLSchema::Sequence; end

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
				@children.each_with_index do |child, i|
					# puts "beg #{child.name} #{check_tail}"
					if check_tail
						raise SmevException.new("Expect #{child.name}, but nothing given") unless child.min_occurs.zero?
						next
					end
					begin
						if child.is_a?(Element)
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
				noko
			end # def


			def load_from_hash hash
				hash.each do |name, value|
					value_size = value.is_a?(Array) ? value.size : 1
					if (childrens = @children.select{|c| c.name == name}).present?
						raise SmevException.new("#{name} have #{value_size} value, but schema doesn't allow this") unless childrens.first.can_occurs(value_size)
						recreate_child name, value_size if childrens.size != value_size

						child_iterator = @children.select{|c| c.name == name}.each
						( value.is_a?(Array) ? value : [value]).each do |val|
							child = child_iterator.next
							child.load_from_hash({name => val})
						end
					else
						@children.select{|c| not c.is_a?(Element)}.each{|child| child.load_from_hash({name => value}) }
					end
				end
			end


		end 
	end
end