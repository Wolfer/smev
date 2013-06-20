require 'wsdl/importer'

module WSDL
  class Definitions

    def find_by_action action, output = false
      #FIXME find from all
      #ищем операцию и  описывающий ещё wsdl:message
      raise Error.new("operation '#{action}' not found") unless op = self.porttypes.first.operations.find{ |o| o.name == action }

      mes = ( output ? op.output : op.input).message
      # что то делаем... РАЗОБРАТЬ
      ps = self.bindings.first.operations.find{ |o| o.name == action }.input.soapbody.parts
      #находим части messag
      self.collect_elements.find_name self.message( mes ).parts.find{|p| ps.present? ? p.name == ps : true }.element.name
    end

    def soap_actions
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
        @complex_type ||= self.type ? self.root.collect_complextypes[self.type] : self.local_complextype
      end

      def simple_type
        @simple_type ||= self.type ? ( self.root.collect_simpletypes[self.type] || self.type ) : self.local_simpletype
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
        @simple_type ||= self.type ? ( self.root.collect_simpletypes[self.type] || self.type ) : self.local_simpletype
      end

    end



    class ComplexType
      def content_type
        if @content
          @content
        elsif @complexcontent
          #if this complex content get elementary type Sequence|Choice|...
          case content = @complexcontent.content
          # for restriction just return his content
          when WSDL::XMLSchema::ComplexRestriction
            content.content
          # for extension get basetype and concat with content in Sequence
          when WSDL::XMLSchema::ComplexExtension
            content.content_type
          end
            
        end
      end 
    end

    class ComplexExtension
      def content_type
        seq = Sequence.new
        seq.elements << basetype.content_type
        seq.elements << content if content
        seq
      end
    end

    class SimpleType
      private
        def check_restriction(value)
          @restriction.valid?(value) || raise(Smev::XSD::ValueError.new("#{@name}: cannot accept '#{value}'"))
        end
    end


    class SimpleRestriction

      def base_type
        @base_type ||= (st = self.root.collect_simpletypes[@base]) ? st : nil
      end

      %w(length minlength maxlength pattern enumeration whitespace maxinclusive 
        maxexclusive minexclusive mininclusive totaldigits fractiondigits fixed).each do |attr|
          self.class_eval "
            def #{attr}
              @#{attr} || ( base_type ? base_type.restriction.#{attr} : nil  )
            end
          "
      end

    end


    class Content

      # alias nested_elements_old nested_elements

      # def nested_elements
      #   result = nested_elements_old
      #   if @parent.is_a? WSDL::XMLSchema::ComplexExtension
      #     @parent.instance_eval("@basetype").nested_elements.concat( nested_elements_old )
      #   else
      #     return nested_elements_old
      #   end

      # end

    end

  end


end
