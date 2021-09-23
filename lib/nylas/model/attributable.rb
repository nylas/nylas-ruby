# frozen_string_literal: true

module Nylas
  module Model
    # Allows defining of typecastable attributes on a model
    module Attributable
      def self.included(model)
        model.extend(ClassMethods)
      end

      def initialize(**initial_data)
        assign(**initial_data)
      end

      def attributes
        @attributes ||= Attributes.new(self.class.attribute_definitions)
      end

      # @return [Hash] Representation of the model with values serialized into primitives based on their Type
      def to_h
        attributes.to_h
      end

      protected

      def assign(**data)
        data.each do |attribute_name, value|
          next if value.nil?

          if respond_to?(:"#{attribute_name}=")
            send(:"#{attribute_name}=", value)
          end
        end
      end

      # Methods to call when tweaking Attributable classes
      module ClassMethods
        # rubocop:disable Naming/PredicateName
        def has_n_of_attribute(name, type_name, read_only: false, default: [])
          attribute_definitions[name] = ListAttributeDefinition.new(
            type_name: type_name,
            read_only: read_only,
            default: default
          )
          define_accessors(name)
        end
        # rubocop:enable Naming/PredicateName

        def attribute(name, type_name, read_only: false, default: nil)
          attribute_definitions[name] = AttributeDefinition.new(
            type_name: type_name,
            read_only: read_only,
            default: default
          )
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

        # Allows a class to inherit parent's attributes
        def inherit_attributes
          return if superclass.nil?

          parent_attributes = superclass.attribute_definitions
          parent_attributes.each do |parent_attribute|
            name = parent_attribute[0]
            attr = parent_attribute[1]
            next if attribute_definitions.key?(name)

            attribute_definitions[name] = attr
            define_accessors(name)
          end
        end

        def attribute_definitions
          @attribute_definitions ||= Registry.new
        end
      end
    end
  end
end
