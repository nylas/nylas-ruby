module Nylas
  module Model
    module Attributable
      def self.included(model)
        model.extend(ClassMethods)
      end

      def initialize(**initial_data)
        initial_data.each do |attribute_name, value|
          self.send(:"#{attribute_name}=", value)
        end
      end

      def attributes
        @attributes ||= Attributes.new(self.class.attribute_definitions)
      end

      # @return [Hash] Representation of the model with values serialized into primitives based on their Type
      def to_h
        attributes.to_h
      end

      module ClassMethods
        def has_n_of_attribute(name, type_name, exclude_when: [], default: [])
          attribute_definitions[name] = ListAttributeDefinition.new(type_name: type_name, exclude_when: exclude_when)
          define_accessors(name)
        end

        def attribute(name, type_name, exclude_when: [], default: nil)
          attribute_definitions[name] = AttributeDefinition.new(type_name: type_name, exclude_when: exclude_when, default: default)
          define_accessors(name)
        end

        def define_accessors(name)
          define_method :"#{name}" do
            attributes[name]
          end

          define_method :"#{name}=" do |value|
            attributes[name] = value
          end
        end

        def attribute_definitions
          @attribute_definitions ||= Registry.new
        end
      end
    end
  end
end
