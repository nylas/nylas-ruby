# frozen_string_literal: true

module Nylas
  module Model
    # Stores the actual model data to allow for type casting and clean/dirty checking
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
        data[key] = cast(key, value)
      rescue Nylas::Registry::MissingKeyError
        # Don't crash when a new attribute is added
      end

      # Merges data into the registry while casting input types correctly
      def merge(new_data)
        new_data.each do |attribute_name, value|
          self[attribute_name] = value
        end
      end

      # Convert the object to hash
      # @param keys [Array<String>] The keys included
      # @param enforce_read_only [Boolean] Whether to enforce read_only property (serializing for API)
      # @return [Hash] The hash representation of the object
      def to_h(keys: attribute_definitions.keys, enforce_read_only: false)
        casted_data = {}
        keys.each do |key|
          value = attribute_to_hash(key, enforce_read_only)
          # If the value is an empty hash but we specify that it is valid (via default value), serialize it
          casted_data[key] = value unless value.nil? || (value.respond_to?(:empty?) && value.empty? &&
            !(attribute_definitions[key].default == value && value.is_a?(Hash)))
        end
        casted_data
      end

      # Serialize the object
      # @param keys [Array<String>] The keys included
      # @param enforce_read_only [Boolean] Whether to enforce read_only property (serializing for API)
      # @return [String] The serialized object as a JSON string
      def serialize(keys: attribute_definitions.keys, enforce_read_only: false)
        JSON.dump(to_h(keys: keys, enforce_read_only: enforce_read_only))
      end

      # Serialize the object to an API-compatible JSON string
      # @param keys [Array<String>] The keys included
      # @return [String] The serialized object as a JSON string
      def serialize_for_api(keys: attribute_definitions.keys)
        serialize(keys: keys, enforce_read_only: true)
      end

      def serialize_all_for_api(keys: attribute_definitions.keys)
        api_keys = keys.delete_if { |key| attribute_definitions[key].read_only == true }

        JSON.dump(
          api_keys.each_with_object({}) do |key, casted_data|
            casted_data[key] = attribute_definitions[key].serialize(self[key])
          end
        )
      end

      private

      def cast(key, value)
        attribute_definitions[key].cast(value)
      rescue TypeError => e
        raise TypeError, "#{key} #{e.message}"
      end

      def default_attributes
        attribute_definitions.keys.zip([]).to_h
      end

      # Convert the attribute value as a hash
      # @param key [String] The attribute's key
      # @param enforce_read_only [Boolean] Whether to enforce read_only property (serializing for API)
      # @return [nil | Hash] The appropriately serialized value
      def attribute_to_hash(key, enforce_read_only)
        attribute_definition = attribute_definitions[key]
        if enforce_read_only
          attribute_definition.read_only == true ? nil : attribute_definition.serialize_for_api(self[key])
        else
          attribute_definition.serialize(self[key])
        end
      end
    end
  end
end
