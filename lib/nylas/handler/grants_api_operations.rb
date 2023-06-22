# frozen_string_literal: true

require_relative "http_client"

module Nylas
  # Allows resources to perform CRUD operations on the API endpoints
  # without exposing the HTTP client to the end user.
  module GrantsApiOperations
    # Create
    module Create
      include HttpClient

      # Create a Nylas object
      # @param identifier [String] The grant ID or email to create in
      # @param query_params [Hash] The query params to pass to the request
      # @param request_body [Hash] The request body to pass to the request
      # @return [Array(Hash, String)] The created Nylas object and API Request ID
      def create(identifier:, query_params: {}, request_body: nil)
        execute(
          method: :post,
          path: "#{host}/grants/#{identifier}/#{resource_name}",
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # List
    module List
      include HttpClient

      # List Nylas objects
      # @param identifier [String] The grant ID or email account to query
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(Hash, String)] The list of Nylas objects and API Request ID
      def list(identifier:, query_params: {})
        execute(
          method: :get,
          path: "#{host}/grants/#{identifier}/#{resource_name}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Find
    module Find
      include HttpClient

      # Find a Nylas object
      # @param identifier [String] The grant ID or email account to query
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(Hash, String)] The Nylas object and API Request ID
      def find(identifier:, object_id:, query_params: {})
        execute(
          method: :get,
          path: "#{host}/grants/#{identifier}/#{resource_name}/#{object_id}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Update
    module Update
      include HttpClient

      # Update a Nylas object
      # @param identifier [String] The grant ID or email account to update in
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @param request_body [Hash] The request body to pass to the request
      # @return [Array(Hash, String)] The updated Nylas object and API Request ID
      def update(identifier:, object_id:, query_params: {}, request_body: nil)
        execute(
          method: :put,
          path: "#{host}/grants/#{identifier}/#{resource_name}/#{object_id}",
          query: query_params,
          payload: request_body,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Destroy
    module Destroy
      include HttpClient

      # Delete a Nylas object
      # @param identifier [String] The grant ID or email account to delete from
      # @param object_id [String] The ID of the object
      # @param query_params [Hash] The query params to pass to the request
      # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
      def destroy(identifier:, object_id:, query_params: {})
        _, request_id = execute(
          method: :delete,
          path: "#{host}/grants/#{identifier}/#{resource_name}/#{object_id}",
          query: query_params,
          api_key: api_key,
          timeout: timeout
        )

        [true, request_id]
      end
    end
  end
end
