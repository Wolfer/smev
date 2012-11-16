module Smev
	module XSD
		class ComplexType < Node

			def self.build_from_xsd xsd
				super(xsd) do |obj, xsd|
					obj.children = xsd.nested_elements.map do |elem| 
						if elem.minoccurs > 1
							elem.minoccurs.times.map{|i| child_factory elem }
						else
							child_factory elem
						end
					end.flatten
					obj
				end
			end	

			def children
				@children || []
			end

			def name
				self.class.to_s.split("::").last
			end

			def leaf?
				false
			end

			def fill_test
				children.each(&:fill_test)
			end

			def to_xml nss
				self.children.map{|child| child.to_xml(nss) }.delete_if{|c| c.blank?}.join("\n")
			end

			def to_hash
				children.inject({}) do |result, child| 
					hash = child.to_hash
					if child.max_occurs > 1
						result[child.name] ||= []
						result[child.name] << hash.delete(child.name)
					else
						result.merge! hash
					end
					result
				end 
			end

			def self.allow_child 
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

			def load_from_nokogiri doc
				raise NotImplementedError.new
			end

			def as_xsd
				klass = self.class.name.split("::").last.downcase
				children_xsd = self.children.map(&:as_xsd).join()
				str = "<xs:#{klass}"
				if children_xsd.present?
					str << ">#{children_xsd}</xs:#{klass}>"
				else
					str << "/>"
				end
				
			end

			def valid?
				#FIXME TEST THIS
				check = true
				collect_children.group_by(&:name).each do |name, childs| 
					check = false unless childs.first.can_occurs(childs.size)
					childs.each{|child| check = false unless child.valid? }
				end
				check
			end

			def errors
				self.children.inject({}){ |res, child| res[child.name] = child.errors if child.errors.present?; res}
			end

			def recreate_child name, size
				fchild = @children.find{|c| c.name == name }
				position = @children.index(fchild)
				@children.delete_if{|child| child.name == name }
				size.times{ @children.insert(position, fchild.dup) }
			end



		private
			
			def method_missing method, *argv, &block
		#		@children.map{ |child| child.send( method, *argv ) if child.respond_to? method }.compact
				self.children.send method, *argv, &block 
			end

		end
	end
end