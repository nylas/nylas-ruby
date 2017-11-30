module Nylas
  module V2
    class ListAttributeDefinition
      attr_accessor :type, :exclude_when

      def initialize(type:, exclude_when:)
        self.type = type
        self.exclude_when = exclude_when
      end

      def cast(list)
        return [] if list.nil? || list.empty?
        list.map { |item| Types.registry[type].cast(item) }
      end
    end

    class AttributeDefinition
      attr_accessor :type, :exclude_when
      def initialize(type:, exclude_when:)
        self.type = type
        self.exclude_when = exclude_when
      end

      def cast(value)
        Types.registry[type].cast(value)
      end
    end

    class Attributes
      attr_accessor :data, :attribute_definitions

      def initialize(attribute_definitions)
        @attribute_definitions = attribute_definitions
        @data = Registry.new(default_attributes)
      end

      def [](key)
        data[key]
      end

      def []=(key, value)
        data[key] = attribute_definitions[key].cast(value)
      end

      def to_h
        data.reduce({}) do |serialized_data, (key, value)|
          serialized_data[key] = attribute_definitions[key].cast(value)
          serialized_data
        end
      end

      private def default_attributes
        attribute_definitions.keys.zip([]).to_h
      end
    end

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
      attr_accessor :api

      def self.included(model)
        model.include(Attributable)
        model.extend(ClassMethods)
      end

      # @return [Hash] Representation of the model with values serialized into primitives based on their Type
      def to_h
        attributes.to_h
      end

      # @return [String] JSON String of the model.
      def to_json
        JSON.dump(serialize)
      end

      module ClassMethods
        def from_json(json, api)
          data = JSON.parse(json, symbolize_names: true)
          instance = new(**data)
          instance.api = api
          instance
        end
      end
    end
  end
end
