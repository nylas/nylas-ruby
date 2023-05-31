# frozen_string_literal: true

require_relative "http_client"

module Nylas
  # Allows resources to perform CRUD operations on the API endpoints
  # without exposing the HTTP client to the end user.
  module Operations
    # Create
    module Post
      protected

      include HttpClient

      def post(path, query_params: {}, headers: {}, request_body: nil)
        execute(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key
        )
      end
    end

    # Find
    module Get
      protected

      include HttpClient

      def get(path, query_params: {})
        execute(
          method: :get,
          path: path,
          query: query_params,
          api_key: api_key
        )
      end
    end

    # Update
    module Put
      protected

      include HttpClient

      def put(path, query_params: {}, request_body: nil)
        execute(
          method: :put,
          path: path,
          query: query_params,
          payload: request_body,
          api_key: api_key
        )
      end
    end

    # Destroy
    module Delete
      protected

      include HttpClient

      def delete(path, query_params: {})
        execute(
          method: :delete,
          path: path,
          query: query_params,
          api_key: api_key
        )
      end
    end
  end
end
