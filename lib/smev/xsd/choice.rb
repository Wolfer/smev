module Smev
	module XSD
		class Choice < ComplexType

			def parent; WSDL::XMLSchema::Choice; end

			def min_occurs
				children.find{|child| child.min_occurs.zero?}.present? ? 0 : 1
			end

			def to_xml nss
				self.children.each{|child| return child.to_xml(nss) if child.valid? }
				raise SmevException.new("Invalid choice!")
			end

			def valid?
				check = false
				self.children.each{|child| check = true if child.valid? }
				#FIXME do choice validation
				check
			end

			def errors
				self.valid? ? {} : super 
			end

			def to_hash
				self.children.each { |child| return child.to_hash if child.valid? }
				super
			end

			def load_from_nokogiri noko_i, noko = nil
				begin
					unless noko
						before = true
						noko = noko_i.next
					end
					if child = @children.find{|c| c.name == noko.name }
						#if have element
						child.load_from_nokogiri noko	
					elsif ( container = @children.select{|child| not child.is_a?(Element) }).present?
						#try with sub-sequnce\choice
						container.each{|child| noko = child.load_from_nokogiri noko_i, noko }
					else
						raise SmevException.new("Expect #{@children.map(&:name).inspect}, but given #{noko.name}!")
					end
				rescue StopIteration => e
					text = "Except that Choice have element #{@children.map(&:name).inspect}"
					raise SmevException.new(text) unless self.min_occurs.zero?
				end
				noko_i.next unless before
			end

			def load_from_hash hash
				hash.each do |key, val|
					if child = @children.find{|c| c.name == key}
						if val.is_a? Array
							raise SmevException.new("Choice could't have unbounded element #{key}!")
						else
							child.load_from_hash({key => val})
						end
					elsif ( container = @children.select{|child| not child.is_a?(Element) }).present?
						container.each{|child| child.load_from_hash({key => val}) }
					end
				end
			end

			def fill_test
				iterator = children.each
				while !self.valid?
					iterator.next.fill_test
				end
			end

		end
	end
end