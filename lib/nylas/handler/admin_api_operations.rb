# frozen_string_literal: true

require_relative "http_client"
require_relative "api_operations"

module Nylas
  # Allows resources to perform CRUD operations on the Admin API endpoints without exposing the
  # HTTP client to the end user.
  module AdminApiOperations
    include HttpClient
    # Creates a Nylas object.
    module Create
      include ApiOperations::Post
      # Creates a Nylas object.
      #
      # @param query_params [Hash, {}] Query params to pass to the request.
      # @param request_body [Hash, nil] Request body to pass to the request.
      # @return [Array(Hash, String)] Created Nylas object and API Request ID.
      def create(query_params: {}, request_body: nil)
        post(
          path: "#{api_uri}/v3/#{resource_name}",
          query_params: query_params,
          request_body: request_body
        )
      end
    end

    # Lists Nylas objects.
    module List
      include ApiOperations::Get
      # Lists Nylas objects.
      #
      # @param query_params [Hash, {}] Query params to pass to the request.
      # @return [Array(Hash, String)] List of Nylas objects and API Request ID.
      def list(query_params: {})
        get(
          path: "#{api_uri}/v3/#{resource_name}",
          query_params: query_params
        )
      end
    end

    # Finds a Nylas object.
    module Find
      include ApiOperations::Get
      # Finds a Nylas object.
      #
      # @param object_id [String] Object ID.
      # @param query_params [Hash, {}] Query params to pass to the request.
      # @return [Array(Hash, String)] Nylas object and API Request ID.
      def find(object_id:, query_params: {})
        get(
          path: "#{api_uri}/v3/#{resource_name}/#{object_id}",
          query_params: query_params
        )
      end
    end

    # Updates a Nylas object.
    module Update
      include ApiOperations::Put
      # Updates a Nylas object.
      #
      # @param object_id [String] Object ID.
      # @param query_params [Hash, {}] Query params to pass to the request.
      # @param request_body [Hash, nil] Request body to pass to the request.
      # @return [Array(Hash, String)] Updated Nylas object and API Request ID.
      def update(object_id:, query_params: {}, request_body: nil)
        put(
          path: "#{api_uri}/v3/#{resource_name}/#{object_id}",
          query_params: query_params,
          request_body: request_body
        )
      end
    end

    # Deletes a Nylas object.
    module Destroy
      include ApiOperations::Delete
      # Deletes a Nylas object.
      #
      # @param object_id [String] Object ID.
      # @param query_params [Hash, {}] Query params to pass to the request.
      # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
      def destroy(object_id:, query_params: {})
        _, request_id = delete(
          path: "#{api_uri}/v3/#{resource_name}/#{object_id}",
          query_params: query_params
        )

        [true, request_id]
      end
    end
  end
end
