# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Grants
  class Grants < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all grants.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of grants and API Request ID.
    def list(query_params: nil)
      get(
        path: "#{api_uri}/v3/grant",
        query_params: query_params
      )
    end

    # Return a grant.
    #
    # @param grant_id [String] The id of the grant to return.
    # @return [Array(Hash, String)] The grant and API request ID.
    def find(grant_id:)
      get(
        path: "#{api_uri}/v3/grant/#{grant_id}"
      )
    end

    # Create a Grant via Custom Authentication.
    #
    # @param request_body [Hash] The values to create the Grant with.
    # @return [Array(Hash, String)] Created grant and API Request ID.
    def create(request_body)
      post(
        path: "#{api_uri}/v3/#{resource_name}/custom",
        request_body: request_body
      )
    end

    # Updates a grant.
    #
    # @param grant_id [String] The id of the grant to update.
    # @param request_body [Hash] The values to update the grant with
    # @return [Array(Hash, String)] The updated grant and API Request ID.
    def update(grant_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grant/#{grant_id}",
        request_body: request_body
      )
    end

    # Deletes a grant.
    #
    # @param grant_id [String] The id of the grant to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(grant_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grant/#{grant_id}"
      )

      [true, request_id]
    end
  end
end
