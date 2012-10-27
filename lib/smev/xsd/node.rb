module Smev
	module XSD
		class Node

			attr_accessor :children
			attr_accessor :max_occurs
			attr_accessor :min_occurs
			attr_accessor	:errors

			def initialize xsd
				raise NotImplementedError.new
			end	

			def name
				raise NotImplementedError.new
			end

			def leaf?
				!children.present?
			end

			def clone
				new_obj = super
				if self.children
					if self.children.is_a? Array
						array_clone = ->(arr) { arr.map{|elem| elem.is_a?(Array) ? array_clone[elem] : elem.clone } }
						new_obj.children = array_clone[ self.children ]
					else
						new_obj.children = self.children.clone
					end
				end
				new_obj
			end

			def as_hash
				hash = { "name" => self.name, 
								 "type" => self.class.name.split("::").last.downcase,
								 "min_occurs" => (self.min_occurs||1), 
								 "max_occurs" => (self.max_occurs||1) }
				hash["children"] = self.children.map{|child| child.as_hash } unless self.leaf?
				hash
			end

		private
			
			def child_factory child
				return nil unless child
				raise ArgumentError.new( "#{child.class} not allow into #{self.class}!"  ) unless allow_child.keys.include? child.class
				allow_child[ child.class ].new child
			end

			def allow_child; {}; end

			# # not really use but it's cool
			# def method_missing method, *argv, &block
			# 	puts ">>>#{method}"
			# 	method = method.to_s
			# 	if method.end_with? "="
			# 		eqv = true
			# 		method.gsub!("=",'')
			# 	end
			# 	if child = children.find{|c| c.name == method }
			# 		return ( eqv and leaf? ) ? child = argv.first : child 
			# 	elsif self.attributes.keys.include? method
			# 		return eqv ? self.attributes[method] = argv.first : self.attributes[method]
			# 	else
			# 		super
			# 	end
			# end

		end
	end
end