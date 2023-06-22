# frozen_string_literal: true

require_relative "http_client"

module Nylas
  # Allows resources to perform CRUD operations on the Admin API
  # endpoints without exposing the HTTP client to the end user.
  module AdminApiOperations
    include HttpClient
    # Create a Nylas object
    module Create
      # Create a Nylas object
      # @param query_params [Hash] The query params to pass to the request
      # @param request_body [Hash] The request body to pass to the request
      # @return [Array(Hash, String)] The created Nylas object and API Request ID
      def create(query_params: {}, request_body: nil)
        execute(
          method: :post,
          path: "#{host}/v3/#{resource_name}",
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # List Nylas objects
    module List
      # List Nylas objects
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(Hash, String)] The list of Nylas objects and API Request ID
      def list(query_params: {})
        execute(
          method: :get,
          path: "#{host}/v3/#{resource_name}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Find a Nylas object
    module Find
      # Find a Nylas object
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(Hash, String)] The Nylas object and API Request ID
      def find(object_id:, query_params: {})
        execute(
          method: :get,
          path: "#{host}/v3/#{resource_name}/#{object_id}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Update a Nylas object
    module Update
      # Update a Nylas object
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @param request_body [Hash] The request body to pass to the request
      # @return [Array(Hash, String)] The updated Nylas object and API Request ID
      def update(object_id:, query_params: {}, request_body: nil)
        execute(
          method: :put,
          path: "#{host}/v3/#{resource_name}/#{object_id}",
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Delete a Nylas object
    module Destroy
      # Delete a Nylas object
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
      def destroy(object_id:, query_params: {})
        _, request_id = execute(
          method: :delete,
          path: "#{host}/v3/#{resource_name}/#{object_id}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )

        [true, request_id]
      end
    end
  end
end
