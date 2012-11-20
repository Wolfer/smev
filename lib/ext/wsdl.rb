require 'wsdl/importer'

module WSDL
	class Definitions

		def find_by_action action, output = false
			#FIXME find from all
			#ищем операцию и  описывающий ещё wsdl:message
			op = self.porttypes.first.operations.find{ |o| o.name == action }
			mes = ( output ? op.output : op.input).message
			# что то делаем... РАЗОБРАТЬ
			ps = self.bindings.first.operations.find{ |o| o.name == action }.input.soapbody.parts
			#находим части messag
			self.collect_elements.find_name self.message( mes ).parts.find{|p| ps.present? ? p.name == ps : true }.element.name
		end

		def methods
			self.porttypes.map { |pt| pt.operations.map(&:name) }.flatten.uniq
		end

	end

	module XMLSchema

		class Element

			attr_accessor :value

			def children
				self.complex_type ? self.complex_type.nested_elements : XSD::NamedElements::Empty
			end
			
			def complex_type
				@complex_type ||= self.type ? self.root.collect_complextypes.find_name(self.type.name) : self.local_complextype
			end

			def simple_type
				@simple_type ||= self.type ? ( self.root.collect_simpletypes.find_name(self.type.name) || self.type ) : self.local_simpletype
			end

			def search_child name
				result = self.children.find_name( name )
				if result.nil?
					self.children.each do |c| 
						next unless c.is_a? self.class
						result = c.search_child name 
						return result if result
					end
				end
				result
			end
		
		end




		class Attribute

			attr_accessor :value

			def simple_type
				@simple_type ||= self.type ? ( self.root.collect_simpletypes.find_name(self.type.name) || self.type ) : self.local_simpletype
			end

		end



		class Pattern

			def parse_attr(attr, value) 
				case attr 
				when ValueAttrName 
					parent.pattern = /#{value.source}/n
					value.source 
				end 
			end 

		end



		class ComplexType
			def content_type
				@content ?  @content : ( @complexcontent and @complexcontent.content.content )
			end 
		end

		class SimpleType
			private
				def check_restriction(value)
					@restriction.valid?(value) || raise(Smev::XSD::ValueError.new("#{@name}: cannot accept '#{value}'"))
				end
		end


		class Content

			alias nested_elements_old nested_elements

			def nested_elements
				result = nested_elements_old
				if @parent.is_a? WSDL::XMLSchema::ComplexExtension
					@parent.instance_eval("@basetype").nested_elements.concat( nested_elements_old )
				else
					return nested_elements_old
				end

			end

		end

	end


end