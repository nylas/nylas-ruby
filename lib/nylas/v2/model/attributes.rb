module Nylas
  module V2
    module Model
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
    end
  end
end
