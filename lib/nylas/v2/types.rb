module Nylas
  module V2
    module Types
      def self.registry
        @registry ||= Registry.new
      end

      class HashType
        def serialize(object)
          to_h
        end

        def self.casts_to(model)
          @casts_to_model = model
        end

        def self.casts_to_model
          @casts_to_model
        end

        def model
          self.class.casts_to_model
        end

        def cast(value)
          return value if already_cast?(value)
          return model.new(**actual_attributes(value)) if value.respond_to?(:key?)
          raise TypeError, "Unable to cast #{value} to a #{model}"
        end

        def already_cast?(value)
          model.attribute_definitions.keys.all? { |attribute_name| value.respond_to?(attribute_name) }
        end

        def actual_attributes(hash)
          model.attribute_definitions.keys.reduce({}) do |attributes, attribute_name|
            attributes[attribute_name] = hash[attribute_name]
            attributes
          end
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
          return value.iso8601 if value.respond_to?(:iso8601)
          value
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

    end
  end
end
