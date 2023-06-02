# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  # Grants
  class Grants < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("grants", sdk_instance)
    end

    # Create a grant
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The created grant object and API Request ID
    def create(query_params: {}, request_body: nil)
      post(
        "#{host}/grants",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Find a grant
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Hash, String)] The grant object and API Request ID
    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params
      )
    end

    # List all grants
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Array, String)] The list of grants and API Request ID
    def list(query_params: {})
      get(
        "#{host}/grants",
        query_params: query_params
      )
    end

    # Update a grant
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The updated grant object and API Request ID
    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Delete a grant
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
    def destroy(path_params: {}, query_params: {})
      _, request_id = delete(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params
      )

      [true, request_id]
    end
  end
end
