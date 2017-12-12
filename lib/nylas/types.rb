module Nylas
  # Collection of attribute types
  module Types
    def self.registry
      @registry ||= Registry.new
    end

    # Type for attributes that are persisted in the API as a hash but exposed in ruby as a particular
    # structure
    class HashType
      def serialize(object)
        object.to_h
      end

      def self.casts_to(model)
        @casts_to_model = model
      end

      class << self
        attr_reader :casts_to_model
      end

      def model
        self.class.casts_to_model
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
          attributes[attribute_name] = hash[attribute_name]
        end
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
        value.to_s
      end
    end
    Types.registry[:string] = StringType.new

    # Type for attributes represented as booleans.
    class BooleanType < ValueType
      # @param value [Object] Strictly casts the passed in value to a boolean (must be true, not "" or 1)
      def cast(value)
        value == true
      end
    end
    Types.registry[:boolean] = BooleanType.new
  end
end
