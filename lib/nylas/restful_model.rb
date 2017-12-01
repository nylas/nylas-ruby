require 'nylas/time_attr_accessor'
require 'nylas/parameters'

module Nylas
  class RestfulModel
    extend Nylas::TimeAttrAccessor
    include Nylas::Parameters

    parameter :id
    parameter :account_id
    parameter :cursor  # Only used by the delta sync API
    time_attr_accessor :created_at
    attr_reader :raw_json

    def self.collection_name
      "#{self.to_s.downcase}s".split('::').last
    end

    def initialize(api, account_id = nil)
      raise StandardError.new unless api.class <= Nylas::API
      @account_id = account_id
      @_api = api
    end

    def ==(comparison_object)
      comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && comparison_object.id == id)
    end

    def inflate(json)
      @raw_json = json
      parameters.each do |property_name|
        send("#{property_name}=", json[property_name]) if json.has_key?(property_name)
      end
    end

    def save!(params={})
      if id
        update('PUT', '', as_json(), params)
      else
        update('POST', '', as_json(), params)
      end
    end

    def path_for(action="")
      action = "/#{action}" unless action.empty?
      "/#{self.class.collection_name}/#{id}#{action}"
    end

    def url(action = "")
      @_api.url_for_path(path_for(action))
    end

    def as_json(options = {})
      hash = {}
      parameters.each do |getter|
        unless options[:except] && options[:except].include?(getter)
          value = send(getter)
          unless value.is_a?(RestfulModelCollection)
            value = value.as_json(options) if value.respond_to?(:as_json)
            hash[getter] = value
          end
        end
      end
      hash
    end

    def update(http_method, action, data = {}, params = {})
      @_api.execute(
        method: http_method,
        url: url(action),
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
      @_api.delete(url: url, params: params) do |response, _request, result|
        Nylas.interpret_response(result, response, raw_response: true)
      end
    end
  end
end
