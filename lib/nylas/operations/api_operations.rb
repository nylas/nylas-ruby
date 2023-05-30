# frozen_string_literal: true

require_relative "http_client"

module Nylas
  # Allows resources to perform CRUD operations on the API endpoints
  # without exposing the HTTP client to the end user.
  module Operations
    # Create
    module Create
      include HttpClient

      def i_create(path, query_params: {}, request_body: nil)
        execute(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          api_key: api_key
        )
      end
    end

    # Find
    module Find
      include HttpClient

      def i_find(path, query_params: {})
        execute(
          method: :get,
          path: path,
          query: query_params,
          api_key: api_key
        )
      end
    end

    # List
    module List
      include HttpClient

      def i_list(path, query_params: {})
        execute(
          method: :get,
          path: path,
          query: query_params,
          api_key: api_key
        )
      end
    end

    # Update
    module Update
      include HttpClient

      def i_update(path, query_params: {}, request_body: nil)
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
    module Destroy
      include HttpClient

      def i_destroy(path, query_params: {})
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
