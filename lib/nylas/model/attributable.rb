module Nylas
  module Model
    # Allows defining of tyypecastable attributes on a model
    module Attributable
      def self.included(model)
        model.extend(ClassMethods)
      end

      def initialize(**initial_data)
        assign(**initial_data)
      end

      protected def assign(**data)
        data.each do |attribute_name, value|
          if respond_to?(:"#{attribute_name}=")
            send(:"#{attribute_name}=", value)
          else
            Logging.logger.warn("#{attribute_name} is not defined as an attribute on #{self.class.name}")
          end
        end
      end

      def attributes
        @attributes ||= Attributes.new(self.class.attribute_definitions)
      end

      # @return [Hash] Representation of the model with values serialized into primitives based on their Type
      def to_h
        attributes.to_h
      end

      # Methods to call when tweaking Attributable classes
      module ClassMethods
        # rubocop:disable Naming/PredicateName
        def has_n_of_attribute(name, type_name, exclude_when: [], default: [])
          attribute_definitions[name] = ListAttributeDefinition.new(type_name: type_name,
                                                                    exclude_when: exclude_when,
                                                                    default: default)
          define_accessors(name)
        end
        # rubocop:enable Naming/PredicateName

        def attribute(name, type_name, exclude_when: [], default: nil)
          attribute_definitions[name] = AttributeDefinition.new(type_name: type_name,
                                                                exclude_when: exclude_when, default: default)
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
