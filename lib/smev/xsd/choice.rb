module Smev
	module XSD
		class Choice < ComplexType

			def parent; WSDL::XMLSchema::Choice; end

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
				self.children.each do |child| 
					next unless child.valid?
					h = child.to_hash
					return h if h.values.first.present?
				end

				super
			end

			def load_from_nokogiri nokogiris
				raise SmevException.new("Choice give more then one element: #{nokogiris.map(&:name).inspect}!") if nokogiris.size != 1
				noko = nokogiris.first
				raise SmevException.new("Expect #{@children.map(&:name).inspect}, but given #{noko.name}!") unless child = @children.find{|c| c.name == noko.name }
				child.load_from_nokogiri noko
			end

			def load_from_hash hash
				raise SmevException.new("Choice give more then one element: #{hash.keys.inspect}!") if hash.keys.size != 1
				key = hash.keys.first
				raise SmevException.new("Expect #{@children.map(&:name).inspect}, but given #{hash.keys.first}!") unless child = @children.find{|c| c.name == key }
				child.load_from_hash hash[key]
			end

		end
	end
end