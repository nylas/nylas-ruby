# frozen_string_literal: true

require_relative "model/attribute_definition"
require_relative "model/list_attribute_definition"
require_relative "model/attributable"
require_relative "model/attributes"
module Nylas
  # Include this to define a class to represent an object returned from the API
  module Model
    attr_accessor :api

    def model_class
      self.class
    end

    def self.included(model)
      model.include(Attributable)
      model.extend(ClassMethods)
      model.extend(Forwardable)
      model.def_delegators :model_class, :creatable?, :filterable?, :listable?, :searchable?, :showable?,
                           :updatable?, :destroyable?
      model.allows_operations
    end

    def save
      result = if persisted?
                 raise ModelNotUpdatableError, self unless updatable?

                 execute(method: :put, payload: attributes.serialize, path: resource_path)
               else
                 create
               end
      attributes.merge(result)
    end

    def persisted?
      !id.nil?
    end

    def execute(method:, payload: nil, path:)
      api.execute(method: method, payload: payload, path: path)
    end

    def create
      raise ModelNotCreatableError, self unless creatable?

      execute(method: :post, payload: attributes.serialize, path: resources_path)
    end

    def update(**data)
      raise ModelNotUpdatableError, model_class unless updatable?

      attributes.merge(**data)
      execute(method: :put, payload: attributes.serialize(keys: data.keys), path: resource_path)
      true
    rescue Registry::MissingKeyError => e
      raise ModelMissingFieldError.new(e.key, self)
    end

    def reload
      assign(execute(method: :get, path: resource_path))
      true
    end

    def resource_path
      "#{resources_path}/#{id}"
    end

    def resources_path
      self.class.resources_path(api: api)
    end

    def destroy
      raise ModelNotDestroyableError, self unless destroyable?

      execute(method: :delete, path: resource_path)
    end

    # @return [String] JSON String of the model.
    def to_json
      JSON.dump(to_h)
    end

    # Allows you to narrow in exactly what kind of model you're working with
    module ClassMethods
      attr_accessor :raw_mime_type, :creatable, :showable, :filterable, :searchable, :listable, :updatable,
                    :destroyable
      attr_writer :resources_path

      # rubocop:disable Metrics/ParameterLists
      def allows_operations(creatable: false, showable: false, listable: false, filterable: false,
                            searchable: false, updatable: false, destroyable: false)

        self.creatable ||= creatable
        self.showable ||= showable
        self.listable ||= listable
        self.filterable ||= filterable
        self.searchable ||= searchable
        self.updatable ||= updatable
        self.destroyable ||= destroyable
      end

      # rubocop:enable Metrics/ParameterLists
      def creatable?
        creatable
      end

      def showable?
        showable
      end

      def listable?
        listable
      end

      def filterable?
        filterable
      end

      def searchable?
        searchable
      end

      def updatable?
        updatable
      end

      def destroyable?
        destroyable
      end

      def resources_path(*)
        @resources_path
      end

      def exposable_as_raw?
        !raw_mime_type.nil?
      end

      def from_json(json, api:)
        from_hash(JSON.parse(json, symbolize_names: true), api: api)
      end

      def from_hash(data, api:)
        instance = new(**data.merge(api: api))
        instance
      end
    end
  end
end
