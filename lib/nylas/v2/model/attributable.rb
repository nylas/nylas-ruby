module Nylas
  module V2
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

        module ClassMethods
          def has_n_of_attribute(name, type, exclude_when: [])
            attribute_definitions[name] = ListAttributeDefinition.new(type: type, exclude_when: exclude_when)
            define_accessors(name)
          end

          def attribute(name, type, exclude_when: [])
            attribute_definitions[name] = AttributeDefinition.new(type: type, exclude_when: exclude_when)
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
end
