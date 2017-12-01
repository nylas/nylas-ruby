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


      def save
      end

      def update(**data)
        attributes.merge(data)
        api.execute(method: :put, body: attributes.to_h(keys: data.keys), path: resource_path)
      end

      def resource_path
        "#{self.class.base_location}/#{id}"
      end


      def destroy
        api.execute(method: :delete, path: resource_path)
      end

      # @return [String] JSON String of the model.
      def to_json
        JSON.dump(to_h)
      end

      module ClassMethods
        attr_accessor :base_location

        def from_json(json, api: api)
          data = JSON.parse(json, symbolize_names: true)
          instance = new(**data)
          instance.api = api
          instance
        end
      end
    end
  end
end
