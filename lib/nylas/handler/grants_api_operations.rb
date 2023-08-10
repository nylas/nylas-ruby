# frozen_string_literal: true

require_relative "http_client"
require_relative "api_operations"

module Nylas
  # Allows resources to perform CRUD operations on the Grants API endpoints without exposing the
  #   HTTP client to the end user.
  module GrantsApiOperations
    # Create a Nylas object.
    module Create
      include ApiOperations::Post
      # Create a Nylas object.
      #
      # @param identifier [String] The Grant ID or email account in which to create the object.
      # @param query_params [Hash, {}] The query params to pass to the request.
      # @param request_body [Hash, nil] The request body to pass to the request. Defaults to `nil`.
      # @return [Array(Hash, String)] The created Nylas object and API Request ID.
      def create(identifier:, query_params: {}, request_body: nil)
        post(
          path: "#{host}/v3/grants/#{identifier}/#{resource_name}",
          query_params: query_params,
          request_body: request_body
        )
      end
    end

    # List Nylas objects.
    module List
      include ApiOperations::Get
      # List Nylas objects.
      #
      # @param identifier [String] The Grant ID or email account to query.
      # @param query_params [Hash, {}] The query params to pass to the request.
      # @return [Array(Hash, String)] The list of Nylas objects and API Request ID.
      def list(identifier:, query_params: {})
        get(
          path: "#{host}/v3/grants/#{identifier}/#{resource_name}",
          query_params: query_params
        )
      end
    end

    # Find a Nylas object.
    module Find
      include ApiOperations::Get
      # Find a Nylas object.
      #
      # @param identifier [String] The Grant ID or email account to query.
      # @param object_id [String] The ID of the object.
      # @param query_params [Hash, {}] The query params to pass to the request.
      # @return [Array(Hash, String)] The Nylas object and API Request ID.
      def find(identifier:, object_id:, query_params: {})
        get(
          path: "#{host}/v3/grants/#{identifier}/#{resource_name}/#{object_id}",
          query_params: query_params
        )
      end
    end

    # Update a Nylas object.
    module Update
      include ApiOperations::Put
      # Update a Nylas object.
      #
      # @param identifier [String] The Grant ID or email account in which to update an object.
      # @param object_id [String] The ID of the object.
      # @param query_params [Hash, {}] The query params to pass to the request.
      # @param request_body [Hash, nil] The request body to pass to the request. Defaults to `nil`.
      # @return [Array(Hash, String)] The updated Nylas object and API Request ID.
      def update(identifier:, object_id:, query_params: {}, request_body: nil)
        put(
          path: "#{host}/v3/grants/#{identifier}/#{resource_name}/#{object_id}",
          query_params: query_params,
          request_body: request_body
        )
      end
    end

    # Delete a Nylas object.
    module Destroy
      include ApiOperations::Delete
      # Delete a Nylas object.
      #
      # @param identifier [String] The Grant ID or email account from which to delete an object.
      # @param object_id [String] The ID of the object.
      # @param query_params [Hash, {}] The query params to pass to the request.
      # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
      def destroy(identifier:, object_id:, query_params: {})
        _, request_id = delete(
          path: "#{host}/v3/grants/#{identifier}/#{resource_name}/#{object_id}",
          query_params: query_params
        )

        [true, request_id]
      end
    end
  end
end
