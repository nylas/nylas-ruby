# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Events API
  class Events < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all events.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of events and API Request ID.
    def list(identifier:, query_params:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/events",
        query_params: query_params
      )
    end

    # Return an event.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param event_id [String] The id of the event to return.
    # @param query_params [Hash] The query parameters to include in the request
    # @return [Array(Hash, String)] The event and API request ID.
    def find(identifier:, event_id:, query_params:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}",
        query_params: query_params
      )
    end

    # Create an event.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the event with.
    # @param query_params [Hash] The query parameters to include in the request.
    # @return [Array(Hash, String)] The created event and API Request ID.
    def create(identifier:, request_body:, query_params:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/events",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Update an event.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param event_id [String] The id of the event to update.
    # @param request_body [Hash] The values to update the event with
    # @param query_params [Hash] The query parameters to include in the request
    # @return [Array(Hash, String)] The updated event and API Request ID.
    def update(identifier:, event_id:, request_body:, query_params:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Delete an event.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param event_id [String] The id of the event to delete.
    # @param query_params [Hash] The query parameters to include in the request
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, event_id:, query_params:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}",
        query_params: query_params
      )

      [true, request_id]
    end
  end
end
