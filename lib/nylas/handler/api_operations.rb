# frozen_string_literal: true

module Nylas
  # Allows resources to perform API operations on the Nylas API
  # endpoints without exposing the HTTP client to the end user.
  module ApiOperations
    # Performs a GET call to the Nylas API
    module Get
      protected

      include HttpClient
      def get(path:, query_params: {})
        execute(
          method: :get,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Performs a POST call to the Nylas API
    module Post
      protected

      include HttpClient
      def post(path:, query_params: {}, request_body: nil)
        execute(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Performs a PUT call to the Nylas API
    module Put
      protected

      include HttpClient
      def put(path:, query_params: {}, request_body: nil)
        execute(
          method: :put,
          path: path,
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Performs a PATCH call to the Nylas API
    module Patch
      protected

      include HttpClient
      def patch(path:, query_params: {}, request_body: nil)
        execute(
          method: :patch,
          path: path,
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Performs a DELETE call to the Nylas API
    module Delete
      protected

      include HttpClient
      def delete(path:, query_params: {})
        execute(
          method: :post,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )
      end
    end
  end
end
