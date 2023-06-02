# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"
# require other mixins as needed

module Nylas
  # redirect uris
  class RedirectURIs < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("redirect-uris", sdk_instance)
    end

    # Add new redirect URI to existing application
    # @param [Hash] request_body The request body to pass to the request
    # @return [Array(Hash, String)] The redirect URI object and API Request ID
    def create(request_body: nil)
      post(
        "#{host}/applications/#{resource_name}",
        request_body: request_body
      )
    end

    # Get a specific redirect URI
    # @param path_params [Hash] The path params to pass to the request
    # @return [Array(Hash, String)] The redirect URI object and API Request ID
    def find(path_params: {})
      get(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}"
      )
    end

    # Get all Application's Redirect URIs
    # @return [Array(Hash, String)] The list of all redirect URIs and API Request ID
    def list
      get("#{host}/applications/#{resource_name}")
    end

    # Update a redirect URI
    # @param path_params [Hash] The path params to pass to the request
    # @param [Hash] request_body The request body to pass to the request
    # @return [Array(Hash, String)] The updated redirect URI object and API Request ID
    def update(path_params: {}, request_body: nil)
      put(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}",
        request_body: request_body
      )
    end

    # Delete a redirect URI
    # @param path_params [Hash] The path params to pass to the request
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
    def destroy(path_params: {})
      _, request_id = delete(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}"
      )

      [true, request_id]
    end
  end
end
