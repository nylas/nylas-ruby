require 'restful_model'

module Inbox
  class RestfulModelCollection

    attr_accessor :filters
    
    def initialize(model_class, api, namespace_id, filters = {})
      raise StandardError.new unless api.class <= Inbox::API
      @model_class = model_class
      @filters = filters
      @namespace_id = namespace_id
      @_api = api
    end

    def each
      offset = 0
      chunk_size = 1000
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

    def first
      get_model_collection.first
    end

    def all
      range(0, Float::INFINITY)
    end

    def where(filters)
      collection = self.clone
      collection.filters ||= {}
      collection.filters.merge!(filters)
      collection
    end

    def range(offset = 0, limit = 1000)
      accumulated = []
      finished = false
      chunk_size = 1000

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
      RestClient.delete("#{url}/#{id}")
    end

    def find(id)
      return nil unless id
      get_model(id)
    end

    def build(args)
      for key in args.keys
        args[key.to_s] = args[key] 
      end
      model = @model_class.new(@_api, @namespace_id)
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
      prefix = "/n/#{@namespace_id}" if @namespace_id
      @_api.url_for_path("#{prefix}/#{@model_class.collection_name}")
    end

    private

    def get_model(id)
      model = nil

      RestClient.get("#{url}/#{id}"){ |response,request,result|
        json = Inbox.interpret_response(result, response, {:expected_class => Object})
        if @model_class < RestfulModel
          model = @model_class.new(@_api)
          model.inflate(json)
        else
          model = @model_class.new(json)
        end
      }
      model
    end

    def get_model_collection(offset = 0, limit = 1000)
      filters = @filters.clone
      filters[:offset] = offset
      filters[:limit] = limit
      models = []

      RestClient.get(url, :params => filters){ |response,request,result|
        items = Inbox.interpret_response(result, response, {:expected_class => Array})
        models = inflate_collection(items)
      }
      models
    end

  end
end
