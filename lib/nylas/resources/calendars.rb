# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  # Calendars
  class Calendars < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end

    # Check multiple calendars to find available time slots for a single meeting
    # @param path_params [Hash] The path params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The availability object and API Request ID
    def get_availability(path_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/calendars/availability",
        request_body: request_body
      )
    end

    # Create a calendar
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The created calendar object and API Request ID
    def create(path_params: {}, query_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Find a calendar
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Hash, String)] The calendar object and API Request ID
    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    # List all calendars
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Array, String)] The list of calendars and API Request ID
    def list(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    # Update a calendar
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The updated calendar object and API Request ID
    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Delete a calendar
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [String] The API Request ID for the delete operation
    def destroy(path_params: {}, query_params: {})
      _, request_id = delete(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )

      request_id
    end
  end
end
