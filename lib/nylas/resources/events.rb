# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"
require "uri"

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
    # @return [Array(Array(Hash), String, String)] The list of events, API Request ID, and next cursor.
    def list(identifier:, query_params:)
      get_list(
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
    #   This can include a `notetaker` object with settings for the Notetaker bot.
    # @param query_params [Hash] The query parameters to include in the request.
    # @return [Array(Hash, String)] The created event and API Request ID.
    def create(identifier:, request_body:, query_params:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/events",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Create, update, or delete events in one request (Google and Microsoft).
    #
    # Results follow the operation order. Both 200 and 207 responses return normally;
    # inspect each result's status and error, even when every operation failed.
    # The API validates the operations and batch size. No operations are retried automatically.
    #
    # @param identifier [String] Grant ID or email account in which to modify events.
    # @param request_body [Hash] The batch request.
    # @option request_body [Array<Hash>] :operations The event operations to execute.
    #   Each operation has a :method of "create", "update", or "delete".
    #   Create and update require :body, using the same event Hash as {#create} or {#update}.
    #   Update and delete require :event_id [String].
    # @param query_params [Hash] Query parameters applied to every operation.
    # @option query_params [String] :calendar_id The required calendar ID.
    # @option query_params [Boolean] :notify_participants Defaults to true on the server.
    #   Microsoft does not support false.
    # @option query_params [String] :grant_email Optional grant email.
    # @option query_params [Boolean] :tentative_as_busy Whether tentative events count as busy.
    # @option query_params [String] :select Comma-separated event fields to return.
    # @return [Array(Array<Hash>, String, Hash)] Ordered results, API request ID, and response headers.
    #   Each result has :status [Integer], optional :data [Hash] with the event for a successful
    #   create or update, and optional :error [Hash] with :type [String], :message [String], and
    #   :provider_error [Hash]. A successful delete has no :data. Failed results may include
    #   :retry_after [Numeric] (seconds, including zero) and :provider_event_created [Boolean].
    #   Never retry an operation with :provider_event_created set to true; it would create a duplicate.
    def batch(identifier:, request_body:, query_params:)
      encoded_identifier = URI.encode_www_form_component(identifier).gsub("+", "%20")
      post(
        path: "#{api_uri}/v3/grants/#{encoded_identifier}/events/batch",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Update an event.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param event_id [String] The id of the event to update.
    # @param request_body [Hash] The values to update the event with.
    #   This can include a `notetaker` object with settings for the Notetaker bot.
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

    # Send RSVP. Allows users to respond to events they have been added to as an attendee.
    #
    # @param identifier [String] Grant ID or email account from which to send RSVP with.
    # @param event_id [String] The id of the event to respond to.
    # @param request_body [Hash] The status values to send the RSVP with.
    # @param query_params [Hash] The query parameters to include in the request
    # @return [(Hash, String)] Response object with the API Request ID.
    def send_rsvp(identifier:, event_id:, request_body:, query_params:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}/send-rsvp",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Returns a list of recurring events, recurring event exceptions, and single events
    # from the specified calendar within a given time frame. This is useful when you
    # want to import, store, and synchronize events from the time frame to your application
    #
    # @param identifier [String] Grant ID or email account to import events from.
    # @param query_params [Hash] The query parameters to include in the request
    # @return [(Array(Hash), String, String)] The list of events, API Request ID, and next cursor.
    def list_import_events(identifier:, query_params:)
      get_list(
        path: "#{api_uri}/v3/grants/#{identifier}/events/import",
        query_params: query_params
      )
    end
  end
end
