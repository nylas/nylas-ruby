# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"
# require other mixins as needed

module Nylas
  # Events
  class Events < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("events", sdk_instance)
    end

    # Create an event
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The created event object and API Request ID
    def create(path_params: {}, query_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Find an event
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Hash, String)] The event object and API Request ID
    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    # List all events
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Array, String)] The list of events and API Request ID
    def list(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    # Update an event
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The updated event object and API Request ID
    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Delete an event
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
    def destroy(path_params: {}, query_params: {})
      _, request_id = delete(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )

      [true, request_id]
    end
  end
end
