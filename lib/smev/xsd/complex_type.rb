module Smev
	module XSD
		class ComplexType < Node

			def initialize xsd
				raise SmevException.new("[ERROR] #{self.class} expect #{self.parent}, but given #{xsd.class}\n") unless xsd.is_a? self.parent
				self.min_occurs = xsd.minoccurs
				self.max_occurs = xsd.maxoccurs
				parse_child xsd
			end

			def name
				self.class.to_s
			end

			def leaf?
				false
			end

			def parse_child xsd
				@children = xsd.nested_elements.map do |elem| 
					if elem.minoccurs > 1
						elem.minoccurs.times.map{|i| child_factory elem }
					else
						child_factory elem
					end
				end.flatten
			end

			def to_xml nss
				self.children.map{|child| child.to_xml(nss) }.delete_if{|c| c.blank?}.join("\n")
			end

			def allow_child 
				{ 
					WSDL::XMLSchema::Choice => Choice, 
					WSDL::XMLSchema::Sequence => Sequence, 
					WSDL::XMLSchema::Element => Element,
					WSDL::XMLSchema::Group => Group,
					WSDL::XMLSchema::Any => Any, 
				}
			end


			def parent; '';end

			def collect_children 
				return [] unless self.children.present?
				self.children.map { |child| child.is_a?( Element ) ? child : ( child.respond_to?("collect_children") ? child.collect_children.flatten : [] ) }.flatten
			end


			def load_from_hash hash

				collect_children.group_by(&:name).each do |name, childs| 
					next unless hash.include? name
					if hash[name].is_a? Array
						mas = hash[name]
						if childs.size == mas.size
							childs.each_with_index { |child, i| 
								child.load_from_hash mas[i] 
							}
						else
							#удаляем все unbound-элемент, создаем заново нужное количество и вызывает заполнение из хэша заново для этого элемента
							self.recreate_child name, mas.size
							return self.load_from_hash hash
						end
					else
						childs.first.load_from_hash( hash[name] ) 
					end
				end

			end


			def recreate_child child_name, new_count
				all = @children.find_all{|child| child.name == child_name}
				ind = @children.index(all.first)
				@children -= all
				@children[ind] = new_count.times.inject([]){ |res, i| res << all.first.clone; res }
				@children.flatten!
			end


			def load_from_nokogiri doc
				raise NotImplementedError.new
			end

			def valid?
				#FIXME TEST THIS
				check = true
				collect_children.group_by(&:name).each do |name, childs| 
					check = false unless childs.size.between?( childs.first.min_occurs, (childs.first.max_occurs || 999) )
					childs.each{|child| check = false unless child.valid? }
				end
				check
			end

			def errors
				self.children.inject({}){ |res, child| res[child.name] = child.errors if child.errors.present?; res}
			end

		private
			
			def method_missing method, *argv, &block
		#		@children.map{ |child| child.send( method, *argv ) if child.respond_to? method }.compact
				@children.send method, *argv, &block
			end

		end
	end
end