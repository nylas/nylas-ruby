require_relative 'model/attribute_definition'
require_relative 'model/list_attribute_definition'
require_relative 'model/attributable'
require_relative 'model/attributes'
module Nylas
  module Model
    attr_accessor :api

    def self.included(model)
      model.include(Attributable)
      model.extend(ClassMethods)
      model.searchable = true
      model.read_only = false
    end

    def save
      raise_if_read_only
      result = if id
                 api.execute(method: :put, payload: attributes.serialize, path: resource_path)
               else
                 api.execute(method: :post, payload: attributes.serialize, path: resources_path)
               end
      attributes.merge(result)
    end

    def update(**data)
      raise_if_read_only
      attributes.merge(**data)
      api.execute(method: :put, payload: attributes.serialize(keys: data.keys), path: resource_path)
      true
    end

    def reload
      attributes.merge(api.execute(method: :get, path: resource_path))
      true
    end

    def resource_path
      "#{resources_path}/#{id}"
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

    def raise_if_read_only
      self.class.raise_if_read_only
    end

    module ClassMethods
      attr_accessor :resources_path, :searchable, :read_only

      def read_only?
        read_only
      end

      def raise_if_read_only
        raise NotImplementedError, "#{self} is read only" if read_only?
      end

      def searchable?
        searchable
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
