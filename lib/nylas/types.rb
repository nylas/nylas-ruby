# frozen_string_literal: true

module Nylas
  # Collection of attribute types
  module Types
    def self.registry
      @registry ||= Registry.new
    end

    # Casts/Serializes data that is persisted and used natively as a Hash
    class HashType
      def serialize(object)
        object.to_h
      end

      def cast(value)
        return JSON.parse(value, symbolize_names: true) if value.is_a?(String)
        return value if value.respond_to?(:key)
      end
    end
    Types.registry[:hash] = HashType.new

    # Type for attributes that are persisted in the API as a hash but exposed in ruby as a particular
    # {Model} or Model-like thing.
    class ModelType
      attr_accessor :model

      def initialize(model:)
        self.model = model
      end

      def serialize(object)
        object.to_h
      end

      def cast(value)
        return model.new if value.nil?
        return value if already_cast?(value)
        return model.new(**actual_attributes(value)) if value.respond_to?(:key?)

        raise TypeError, "Unable to cast #{value} to a #{model}"
      end

      def already_cast?(value)
        model.attribute_definitions.keys.all? { |attribute_name| value.respond_to?(attribute_name) }
      end

      def actual_attributes(hash)
        model.attribute_definitions.keys.each_with_object({}) do |attribute_name, attributes|
          attributes[attribute_name] = hash[json_key_from_attribute_name(attribute_name)]
        end
      end

      def json_key_from_attribute_name(name)
        name
      end
    end

    # Type for attributes that do not require casting/serializing/deserializing.
    class ValueType
      def cast(object)
        object
      end

      def serialize(object)
        object
      end

      def deseralize(object)
        object
      end
    end

    # Type for attributes represented as a unix timestamp in the API and Time in Ruby
    class UnixTimestampType
      def cast(object)
        return object if object.is_a?(Time) || object.nil?
        return Time.at(object.to_i) if object.is_a?(String)
        return Time.at(object) if object.is_a?(Numeric)
        return object.to_time if object.is_a?(Date)

        raise TypeError, "Unable to cast #{object} to Time"
      end

      def deserialize(object)
        cast(object)
      end

      def serialize(object)
        return nil if object.nil?
        object.to_i
      end
    end
    Types.registry[:unix_timestamp] = UnixTimestampType.new

    # Type for attributes represented as an iso8601 dates in the API and Date in Ruby
    class DateType < ValueType
      def cast(value)
        return nil if value.nil?

        Date.parse(value)
      end

      def serialize(value)
        return value.iso8601 if value.respond_to?(:iso8601)

        value
      end
    end
    Types.registry[:date] = DateType.new

    # Type for attributes represented as pure strings both within the API and in Ruby
    class StringType < ValueType
      # @param value [Object] Casts the passed in object to a string using #to_s
      def cast(value)
        return value if value.nil?

        value.to_s
      end
    end
    Types.registry[:string] = StringType.new

    # Type for attributes represented as pure integers both within the API and in Ruby
    class IntegerType < ValueType
      # @param value [Object] Casts the passed in object to an integer using to_i
      def cast(value)
        return nil if value.nil?

        value.to_i
      end
    end
    Types.registry[:integer] = IntegerType.new

    # Type for attributes represented as booleans.
    class BooleanType < ValueType
      # @param value [Object] Strictly casts the passed in value to a boolean (must be true, not "" or 1)
      def cast(value)
        return nil if value.nil?
        return true if value == true
        return false if value == false

        raise TypeError, "#{value} must be either true or false"
      end
    end
    Types.registry[:boolean] = BooleanType.new
  end
end
