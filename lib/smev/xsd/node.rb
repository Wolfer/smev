module Smev
	module XSD
		class Node

			attr_accessor :children
			attr_accessor :max_occurs
			attr_accessor :min_occurs
			attr_accessor	:errors

			def self.build_from_xsd xsd
				obj = self.new
				obj.max_occurs = xsd.maxoccurs || 1
				obj.min_occurs = xsd.minoccurs || 1
				yield(obj, xsd) if block_given?
				obj
			end

			def self.build_from_hash hash
				obj = self.new
				obj.max_occurs = hash["max_occurs"] || 1
				obj.min_occurs = hash["min_occurs"] || 1
				obj.children = hash["children"].map{|child| Smev::XSD.const_get(child["type"].capitalize).build_from_hash child } if hash["children"].present?
				yield(obj, hash) if block_given?
				obj
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
			  if self.children.present? and not self.leaf?
			  	hash["children"] = if self.children.respond_to? "as_hash"
						[self.children.as_hash]
					else
						self.children.map{|child| child.as_hash }
					end
				end
				hash
			end

			def as_xsd
				str = []
				str << "minOccurs=\"#{self.min_occurs}\"" if self.min_occurs != 1
				str << "maxOccurs=\"#{self.max_occurs}\"" if self.max_occurs != 1
				str.join(" ").to_s
			end

		private

			def self.child_factory child
				return nil unless child
				raise ArgumentError.new( "#{child.class} not allow into #{self.class}!"  ) if allow_child.is_a?(Hash) and not allow_child.keys.include? child.class
				allow_child[ child.class ].build_from_xsd child
			end

			def self.allow_child
				->(klass){ Smev::XSD.const_get(klass.to_s.split("::").last) }
			end

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