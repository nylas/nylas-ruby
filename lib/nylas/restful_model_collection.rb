require 'nylas/restful_model'

module Nylas
  class RestfulModelCollection

    attr_accessor :filters

    SEARCHABLE_COLLECTIONS = [ Nylas::Thread, Nylas::Message ]

    def initialize(model_class, api, filters = {})
      raise StandardError.new unless api.class <= Nylas::API
      @model_class = model_class
      @filters = filters
      @_api = api
    end

    def search(query)
      raise NameError, "Only #{SEARCHABLE_COLLECTIONS} searchable" unless SEARCHABLE_COLLECTIONS.include?(@model_class)
      get_model_collection(search: query)
    end

    def each
      return enum_for(:each) unless block_given?

      get_model_collection do |items|
        items.each do |item|
          yield item
        end
      end
    end

    def count
      params = @filters.merge(view: 'count')
      @_api.get(url, params: params) do |response, _request, result|
        Nylas.interpret_response(result, response)['count']
      end
    end

    def first
      get_model_collection.first
    end

    def all
      range(0, Float::INFINITY)
    end

    def where(filters)
      collection = self.clone

      # deep copy the object, otherwise filter is shared among all
      # the instances of the collection, which leads to confusing behaviour.
      # - karim
      if collection.filters == nil
        collection.filters = {}
      else
        collection.filters = Marshal.load(Marshal.dump(collection.filters))
      end

      collection.filters.merge!(filters)
      collection
    end

    def range(offset = 0, limit = 100)

      accumulated = get_model_collection(offset: offset, limit: limit)

      accumulated = accumulated[0..limit] if limit < Float::INFINITY
      accumulated
    end

    def delete(item_or_id)
      item_or_id = item_or_id.id if item_or_id.is_a?(RestfulModel)
      @_api.delete("#{url}/#{item_or_id}")
    end

    def find(id)
      return nil unless id
      get_model(id)
    end

    def build(args)
      for key in args.keys
        args[key.to_s] = args[key]
      end
      model = @model_class.new(@_api)
      model.inflate(args)
      model
    end

    def inflate_collection(items = [])
      models = []

      return unless items.is_a?(Array)
      items.each do |json|
        if @model_class < RestfulModel
          model = @model_class.new(@_api)
          model.inflate(json)
        else
          model = @model_class.new(json)
        end
        models.push(model)
      end
      models
    end

    def url
      @_api.url_for_path("/#{@model_class.collection_name}")
    end

    def search_url
      @_api.url_for_path("/#{@model_class.collection_name}/search")
    end

    private

    def get_model(id)
      model = nil

      @_api.get("#{url}/#{id}") do |response, _request, result|
        json = Nylas.interpret_response(result, response, expected_class: Object)
        if @model_class < RestfulModel
          model = @model_class.new(@_api)
          model.inflate(json)
        else
          model = @model_class.new(json)
        end
      end
      model
    end

    def get_model_collection(search: nil,offset: nil, limit: nil, per_page: 100)
      filters = @filters.clone
      filters[:offset] = offset || filters[:offset] || 0
      filters[:limit] = limit || filters[:limit] || 100
      filters[:q] = search unless search.nil?

      accumulated = []

      finished = false

      current_calls_filters = filters.clone
      while (!finished) do
        current_calls_filters[:limit] = per_page > filters[:limit] ? filters[:limit] : per_page
        endpoint = filters.key?(:q) ? search_url : url
        @_api.get(endpoint, params: current_calls_filters) do |response, _request, result|
          items = Nylas.interpret_response(result, response, { :expected_class => Array })
          new_items = inflate_collection(items)
          yield new_items if block_given?
          accumulated = accumulated.concat(new_items)
          finished = no_more_pages?(accumulated, items, filters, per_page)
        end

        current_calls_filters[:offset] += per_page
      end

      accumulated
    end

    def no_more_pages?(accumulated, items, filters, per_page)
      accumulated.length >= filters[:limit] || items.length < per_page
    end
  end


  # a ManagementModelCollection is similar to a RestfulModelCollection except
  # it's used by models under the /a/<app_id> namespace (mostly account status
  # and billing methods).
  class ManagementModelCollection < RestfulModelCollection
    def url
      @_api.url_for_management
    end
  end
end
