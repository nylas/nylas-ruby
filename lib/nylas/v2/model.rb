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
        result = if id
                   api.execute(method: :put, payload: attributes.serialize, path: resource_path)
                 else
                   api.execute(method: :post, payload: attributes.serialize, path: resources_path)
                 end
        attributes.merge(result)
      end

      def update(**data)
        attributes.merge(data)
        api.execute(method: :put, payload: attributes.serialize(keys: data.keys), path: resource_path)
      end

      def resource_path
        self.class.resource_path(id)
      end

      def resources_path
        self.class.resources_path
      end

      def destroy
        api.execute(method: :delete, path: resource_path)
      end

      # @return [String] JSON String of the model.
      def to_json
        JSON.dump(to_h)
      end

      module ClassMethods
        attr_accessor :resources_path

        def resource_path(id)
          "#{resources_path}/#{id}"
        end

        def from_json(json, api:)
          data = JSON.parse(json, symbolize_names: true)
          instance = new(**data)
          instance.api = api
          instance
        end
      end
    end
  end
end
