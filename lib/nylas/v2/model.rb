require_relative 'model/attribute_definition'
require_relative 'model/list_attribute_definition'
require_relative 'model/attributable'
require_relative 'model/attributes'
module Nylas
  module V2
    module Model
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
        JSON.dump(to_h)
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
