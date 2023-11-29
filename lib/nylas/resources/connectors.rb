# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Connectors API
  class Connectors < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Access the Credentials API
    attr_reader :credentials

    # Initializes Connectors.
    def initialize(sdk_instance)
      super(sdk_instance)

      @credentials = Credentials.new(sdk_instance)
    end

    # Return all connectors.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of connectors and API Request ID.
    def list(query_params: nil)
      get(
        path: "#{api_uri}/v3/connectors",
        query_params: query_params
      )
    end

    # Return a connector.
    #
    # @param provider [String] The provider associated to the connector to retrieve.
    # @return [Array(Hash, String)] The connector and API request ID.
    def find(provider:)
      get(
        path: "#{api_uri}/v3/connectors/#{provider}"
      )
    end

    # Create a connector.
    #
    # @param request_body [Hash] The values to create the connector with.
    # @return [Array(Hash, String)] The created connector and API Request ID.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/connectors",
        request_body: request_body
      )
    end

    # Update a connector.
    #
    # @param provider [String] The provider associated to the connector to update.
    # @param request_body [Hash] The values to update the connector with
    # @return [Array(Hash, String)] The updated connector and API Request ID.
    def update(provider:, request_body:)
      put(
        path: "#{api_uri}/v3/connectors/#{provider}",
        request_body: request_body
      )
    end

    # Delete a connector.
    #
    # @param provider [String] The provider associated to the connector to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(provider:)
      _, request_id = delete(
        path: "#{api_uri}/v3/connectors/#{provider}"
      )

      [true, request_id]
    end
  end
end
