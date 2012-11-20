class XPathFinder
	def regex node_set, attr, value
		node_set.find_all { |node| node[attr] == value }
	end
end


Nokogiri::XML::Node.class_eval <<CLASSEVAL

	def search_child name, ns = false
		result = self.children.find_all{ |e| e.name.downcase == name.downcase and ( !ns or e.namespace.href == ns )  } 
		unless result.present?
			self.children.each do |c| 
				result  = c.search_child name, ns
				return result if result.present?
			end
		end
		result
	end

	def humanize tab = ''
		rec = Proc.new { |children| 	children.map{ |child| child.humanize tab+"  " }.join("\n") }
		if self.is_a? Nokogiri::XML::Text
			return tab + self.to_s + "\n"
		else
			return tab + self.name + ":\n" + rec[self.children] + rec[self.attributes.values]	
		end
		
	end


	# def search_child name, *argv
	# 	xpath "//"+name, NAMESPACES, *argv
	# end

	# def get_child path
	# 	finder = lambda do |node, names|
	# 		if names.empty?
	# 			node
	# 		else
	# 			name = names.shift
	# 			finder.call node.children.find{|n| n.name.downcase == name.downcase }, names
	# 		end
	# 	end
	# 	finder.call self, path.split("/")
	# end


	def canonicalize_excl
		canonicalize Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0
	end

CLASSEVAL

