require_relative "model/attribute_definition"
require_relative "model/list_attribute_definition"
require_relative "model/attributable"
require_relative "model/attributes"
module Nylas
  # Include this to define a class to represent an object returned from the API
  module Model
    attr_accessor :api

    def self.included(model)
      model.include(Attributable)
      model.extend(ClassMethods)
      model.collectionable = true
      model.searchable = true
      model.read_only = false
    end

    def save
      raise_if_read_only
      result = if id
                 execute(method: :put, payload: attributes.serialize, path: resource_path)
               else
                 execute(method: :post, payload: attributes.serialize, path: resources_path)
               end
      attributes.merge(result)
    end

    def execute(method:, payload: nil, path:)
      api.execute(method: method, payload: payload, path: path)
    end

    def update(**data)
      raise_if_read_only
      attributes.merge(**data)
      execute(method: :put, payload: attributes.serialize(keys: data.keys), path: resource_path)
      true
    end

    def reload
      attributes.merge(execute(method: :get, path: resource_path))
      true
    end

    def resource_path
      "#{resources_path}/#{id}"
    end

    def resources_path
      self.class.resources_path(api: api)
    end

    def destroy
      execute(method: :delete, path: resource_path)
    end

    # @return [String] JSON String of the model.
    def to_json
      JSON.dump(to_h)
    end

    def raise_if_read_only
      self.class.raise_if_read_only
    end

    # Allows you to narrow in exactly what kind of model you're working with
    module ClassMethods
      attr_accessor :resources_path, :searchable, :read_only, :collectionable

      def read_only?
        read_only == true
      end

      def resources_path(*)
        @resources_path
      end

      def raise_if_read_only
        raise NotImplementedError, "#{self} is read only" if read_only?
      end

      def searchable?
        searchable == true
      end

      def collectionable?
        collectionable == true
      end

      def from_json(json, api:)
        from_hash(JSON.parse(json, symbolize_names: true), api: api)
      end

      def from_hash(data, api:)
        instance = new(**data)
        instance.api = api
        instance
      end
    end
  end
end
