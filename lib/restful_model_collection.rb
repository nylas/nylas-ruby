require 'restful_model'

module Inbox
  class RestfulModelCollection

    attr_accessor :filters

    def initialize(model_class, api, filters = {})
      raise StandardError.new unless api.class <= Inbox::API
      @model_class = model_class
      @filters = filters
      @_api = api
    end

    def each
      return enum_for(:each) unless block_given?

      @filters[:offset] = 0
      @filters[:limit] = 100

      finished = false
      while (!finished) do
        results = get_model_collection()
        results.each { |item|
          yield item
        }
        @filters[:offset] += results.length
        finished = results.length < @filters[:limit]
      end
    end

    def count
      RestClient.get(url, params: @filters.merge(view: 'count')) { |response,request,result|
        json = Inbox.interpret_response(result, response)
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
        #results = get_model_collection(offset + accumulated.length, chunk_size)
        @filters[:offset] = offset + accumulated.length
        # TODO the below means that if we call range(0, 150) we will make two calls for
        # 100 elements each, then cut off the last 50. This could be optimized.
        @filters[:limit] = chunk_size
        results = get_model_collection()
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

    def get_model_collection
      filters = @filters.clone

      # If filters have already been set for limit or offset, ignore the
      # values passed in above. (i.e., the 'where' function has precedence)
      models = []

      RestClient.get(url, :params => filters){ |response,request,result|
        items = Inbox.interpret_response(result, response, {:expected_class => Array})
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
