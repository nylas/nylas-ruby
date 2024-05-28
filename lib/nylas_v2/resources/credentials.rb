# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module NylasV2
  # Nylas Connectors API
  class Credentials < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Patch
    include ApiOperations::Delete

    # Return all credentials.
    #
    # @param provider [String] The provider associated to the credential to list from
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of credentials and API Request ID.
    def list(provider:, query_params: nil)
      get(
        path: "#{api_uri}/v3/connectors/#{provider}/creds",
        query_params: query_params
      )
    end

    # Return a connector.
    #
    # @param provider [String] The provider associated to the connector to retrieve.
    # @param credential_id [String] The id of the credentials to retrieve.
    # @return [Array(Hash, String)] The connector and API request ID.
    def find(provider:, credential_id:)
      get(
        path: "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}"
      )
    end

    # Create a connector.
    #
    # @param provider [String] The provider associated to the credential being created
    # @param request_body [Hash] The values to create the connector with.
    # @return [Array(Hash, String)] The created connector and API Request ID.
    def create(provider:, request_body:)
      post(
        path: "#{api_uri}/v3/connectors/#{provider}/creds",
        request_body: request_body
      )
    end

    # Update a connector.
    #
    # @param provider [String] The provider associated to the connector to update from.
    # @param credential_id [String] The id of the credentials to update.
    # @param request_body [Hash] The values to update the connector with
    # @return [Array(Hash, String)] The updated connector and API Request ID.
    def update(provider:, credential_id:, request_body:)
      patch(
        path: "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}",
        request_body: request_body
      )
    end

    # Delete a connector.
    #
    # @param provider [String] The provider associated to the connector to delete.
    # @param credential_id [String] The id of the credentials to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(provider:, credential_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}"
      )

      [true, request_id]
    end
  end
end
