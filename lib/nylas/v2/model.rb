module Nylas
  module V2
    class Registry
      attr_accessor :registry_data

      extend Forwardable
      def_delegators :registry_data, :keys, :each, :reduce

      def initialize(initial_data = {})
        self.registry_data = initial_data.each.reduce({}) do |registry, (key, value)|
          registry[key] = value
          registry
        end
      end

      def [](key)
        registry_data.fetch(key)
      end

      def []=(key, value)
        registry_data[key] = value
      end

      def to_h
        registry_data
      end
    end

    module Types
      def self.registry
        @registry ||= Registry.new
      end
    end

    class ValueType
      def cast(object)
        object
      end

      # Used to prepare a value for transmission to a storage mechanism, i.e.
      def serialize(object)
        object
      end

      def deseralize(object)
        object
      end
    end

    class DateType < ValueType
      def cast(value)
        return nil if value.nil?
        Date.parse(value)
      end

      def serialize(value)
        Date.strftime("%Y-%m-%d")
      end
    end

    Types.registry[:date] = DateType.new

    class StringType < ValueType
      # @param value [Object] Casts the passed in object to a string using #to_s
      def cast(value)
        value.to_s
      end
    end

    Types.registry[:string] = StringType.new

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

      def serialize_for(use_case: nil)
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

      # @return [Hash] JSON representation of the contact. See {http://example.com/ API documentation}
      def as_json(use_case: nil)
        attributes.serialize_for(use_case: use_case).to_h
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
