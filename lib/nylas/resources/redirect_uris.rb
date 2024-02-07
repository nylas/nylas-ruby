# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # A collection of redirect URI related API endpoints.
  class RedirectUris < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all redirect uris.
    #
    # @return [Array(Array(Hash), String, String)] The list of redirect uris, API Request ID, and next cursor.
    def list
      get_list(
        path: "#{api_uri}/v3/applications/redirect-uris"
      )
    end

    # Return a redirect uri.
    #
    # @param redirect_uri_id [String] The id of the redirect uri to return.
    # @return [Array(Hash, String)] The redirect uri and API request ID.
    def find(redirect_uri_id:)
      get(
        path: "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}"
      )
    end

    # Create a redirect uri.
    #
    # @param request_body [Hash] The values to create the redirect uri with.
    # @return [Array(Hash, String)] The created redirect uri and API Request ID.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/applications/redirect-uris",
        request_body: request_body
      )
    end

    # Update a redirect uri.
    #
    # @param redirect_uri_id [String] The id of the redirect uri to update.
    # @param request_body [Hash] The values to update the redirect uri with
    # @return [Array(Hash, String)] The updated redirect uri and API Request ID.
    def update(redirect_uri_id:, request_body:)
      put(
        path: "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}",
        request_body: request_body
      )
    end

    # Delete a redirect uri.
    #
    # @param redirect_uri_id [String] The id of the redirect uri to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(redirect_uri_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}"
      )

      [true, request_id]
    end
  end
end
