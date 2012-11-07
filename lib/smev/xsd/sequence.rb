module Smev
	module XSD
		class Sequence < ComplexType

			def parent; WSDL::XMLSchema::Sequence; end

			def load_from_nokogiri nokogiris
				children_size = @children.group_by(&:name)
				nokogiris.group_by{|n| n.name}.each do |name, nokos|
					next unless children_size[name] and children_size[name].size != nokos.size
					children_size[name].first.can_occurs nokos.size
					recreate_child name, nokos.size
				end

				children_loader(nokogiris){ |child, noko| child.load_from_nokogiri noko }
							
			end # def

			def load_from_hash hash
				hash.each do |name, value|
					value_size = value.is_a?(Array) ? value.size : 1
					childrens = @children.select{|c| c.name == name}
					raise SmevException.new("#{name} have #{value_size} value, but schema doesn't allow this") unless childrens.first.can_occurs(value_size)
					recreate_child name, value_size if childrens.size != value_size

					child_iterator = @children.select{|c| c.name == name}.each
					( value.is_a?(Array) ? value : [value]).each do |val|
						child = child_iterator.next
						child.load_from_hash({name => val})
					end

				end
			end

		private

			def children_loader args
				arg_iterator = args.each
				arg = arg_iterator.next
				check_tail = false
				ended = false
				@children.each do |child| 
					begin
						if check_tail
							raise SmevException.new("Expect #{child.name}, but nothing given") if not child.min_occurs.zero?
						else
							if yield( child, arg)
								arg = arg_iterator.next 
							end
						end
					rescue SmevException => e
						next if child.min_occurs.zero?
						raise SmevException.new(e.to_s)
					rescue StopIteration => si
						check_tail = true
						ended = true
					end
				end

				if ended
					true
				else
					not_approach = []
					begin
				 		not_approach << arg_iterator.next while(true)
					rescue StopIteration
						raise SmevException.new("Given also #{not_approach.inspect}, but havent elements for this") if not_approach.present?
					end
				end

			end

		end 
	end
end