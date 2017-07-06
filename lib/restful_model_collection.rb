require 'restful_model'

module Nylas
  class RestfulModelCollection

    attr_accessor :filters

    def initialize(model_class, api, filters = {})
      raise StandardError.new unless api.class <= Nylas::API
      @model_class = model_class
      @filters = filters
      @_api = api
    end

    def each
      return enum_for(:each) unless block_given?

      offset = 0
      chunk_size = 100
      finished = false
      while (!finished) do
        results = get_model_collection(offset, chunk_size)
        results.each { |item|
          yield item
        }
        offset += results.length
        finished = results.length < chunk_size
      end
    end

    def count
      RestClient.get(url, params: @filters.merge(view: 'count')) { |response,request,result|
        json = Nylas.interpret_response(result, response)
        return json['count']
      }
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
      accumulated = []
      finished = false
      chunk_size = 100

      if limit < chunk_size
        chunk_size = limit
      end

      while (!finished && accumulated.length < limit) do
        results = get_model_collection(offset + accumulated.length, chunk_size)
        accumulated = accumulated.concat(results)

        # we're done if we have more than 'limit' items, or if we asked for 50 and got less than 50...
        finished = accumulated.length >= limit || results.length == 0 || (results.length % chunk_size != 0)
      end

      accumulated = accumulated[0..limit] if limit < Float::INFINITY
      accumulated
    end

    def delete(item_or_id)
      item_or_id = item_or_id.id if item_or_id.is_a?(RestfulModel)
      RestClient.delete("#{url}/#{item_or_id}")
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

    private

    def get_model(id)
      model = nil

      RestClient.get("#{url}/#{id}"){ |response,request,result|
        json = Nylas.interpret_response(result, response, {:expected_class => Object})
        if @model_class < RestfulModel
          model = @model_class.new(@_api)
          model.inflate(json)
        else
          model = @model_class.new(json)
        end
      }
      model
    end

    def get_model_collection(offset = 0, limit = 100)
      filters = @filters.clone
      filters[:offset] = offset
      filters[:limit] = limit
      models = []

      RestClient.get(url, :params => filters){ |response,request,result|
        items = Nylas.interpret_response(result, response, {:expected_class => Array})
        models = inflate_collection(items)
      }
      models
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
