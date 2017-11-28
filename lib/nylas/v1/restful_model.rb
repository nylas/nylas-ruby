require_relative 'time_attr_accessor'
require_relative 'parameters'

module Nylas
  module V1
    class RestfulModel
      extend Forwardable
      def_delegators :sdk, :client

      private def sdk
        @_api
      end

      extend TimeAttrAccessor
      include Parameters

      parameter :id
      parameter :account_id
      parameter :cursor  # Only used by the delta sync API
      time_attr_accessor :created_at
      attr_reader :raw_json

      def self.collection_name
        "#{self.to_s.downcase}s".split('::').last
      end

      def initialize(api, account_id = nil)
        raise StandardError.new unless api.class <= Nylas::V1::SDK
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

      def url(action = "")
        @_api.url_for_path(action_path(action))
      end

      def action_path(action = "")
        action = "/#{action}" unless action.empty?
        "/#{self.class.collection_name}/#{id}#{action}"
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
        json = client.request(http_method.downcase.to_sym, action_path(action), body: data, query: params)
        unless http_method == 'delete'
          inflate(json)
        end

        self
      end

      def destroy(params = {})
        client.delete(action_path(action), query: params)
      end
    end
  end
end
