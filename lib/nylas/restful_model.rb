require_relative 'model_state'
require_relative 'time_attr_accessor'
require_relative 'parameters'

module Nylas
  class RestfulModel
    extend Nylas::TimeAttrAccessor
    include Nylas::Parameters

    parameter :id
    parameter :account_id
    parameter :cursor  # Only used by the delta sync API
    time_attr_accessor :created_at
    attr_reader :raw_json
    attr_accessor :model_state

    def self.collection_name
      "#{self.to_s.downcase}s".split('::').last
    end

    def initialize(api, account_id = nil)
      raise StandardError.new unless api.class <= Nylas::API
      @model_state = ModelState.new
      @account_id = account_id
      @_api = api
    end

    def ==(comparison_object)
      comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && comparison_object.id == id)
    end

    def inflate(json)
      @raw_json = json
      data = parameters.reduce({}) do |real_properties, property_name|
        real_properties[property_name] = json[property_name] if json.key?(property_name)
        real_properties
      end
      self.model_state = ModelState.new(data)
    end

    def save!(params={})
      if id
        update('PUT', '', as_json(), params)
      else
        update('POST', '', as_json(), params)
      end
    end

    def url(action = "")
      action = "/#{action}" unless action.empty?
      @_api.url_for_path("/#{self.class.collection_name}/#{id}#{action}")
    end

    def as_json(options = {})
      model_state.as_json(options)
    end

    def update(http_method, action, data = {}, params = {})
      @_api.execute(
        http_method,
        url(action),
        payload: data.to_json,
        headers: {
          content_type: :json,
          params: params
        }
      ) do |response, request, result|
        unless request.method == 'delete'
          json = Nylas.interpret_response(result, response, expected_class: Object)
          inflate(json)
        end
      end
      self
    end

    def destroy(params = {})
      @_api.delete(url, nil, params: params) do |response, _request, result|
        Nylas.interpret_response(result, response, raw_response: true)
      end
    end
  end
end
