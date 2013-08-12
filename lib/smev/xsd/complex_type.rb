module Smev
	module XSD
		class ComplexType < Node

			def self.build_from_xsd xsd
				super(xsd) do |obj, xsd|
					obj.children = xsd.elements.map do |elem| 
						if elem.minoccurs > 1
							elem.minoccurs.times.map{|i| child_factory elem }
						else
							child_factory elem
						end
					end
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

			def to_hash short = true
				children.inject({}) do |result, child| 
					hash = child.to_hash(short)
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
				children.group_by(&:name).each do |name, childs| 
					check = false unless childs.first.can_occurs(childs.size)
					childs.each{|child| check = false unless child.valid? or child.min_occurs.zero? }
				end
				check
			end

			def errors
				self.children.inject({}) do|res, child|
					if child.errors.present?
				 		 child.is_a?(Element) ? (res[child.name] = child.errors) : res.merge!(child.errors)
				 	end
				 	res
				end
			end

			def recreate_child name, size
				fchild = @children.find{|c| c.name == name }
				position = @children.index(fchild)
				@children.delete_if{|child| child.name == name }
				size.times{ @children.insert(position, fchild.dup) }
			end

			def remove_child name
				self.children.delete_if do |child|
					if child.is_a? Element
						child.name == name
					else
						child.remove_child name
						false
					end
				end
			end


		private
			
			def method_missing method, *argv, &block
				if self.children.respond_to? method
					self.children.send( method, *argv, &block ) 
				else
					self.children.map{ |child| child.send( method, *argv ) }.compact
				end
			end

		end
	end
end