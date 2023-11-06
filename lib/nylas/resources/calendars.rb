# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Calendar API
  class Calendars < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all calendars.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of calendars and API Request ID.
    def list(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars",
        query_params: query_params
      )
    end

    # Return a calendar.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param calendar_id [String] The id of the calendar to return.
    #   Use "primary" to refer to the primary calendar associated with grant.
    # @return [Array(Hash, String)] The calendar and API request ID.
    def find(identifier:, calendar_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}"
      )
    end

    # Creates a calendar.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the calendar with.
    # @return [Array(Hash, String)] The created calendar and API Request ID.
    def create(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars",
        request_body: request_body
      )
    end

    # Updates a calendar.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param calendar_id [String] The id of the calendar to update.
    #   Use "primary" to refer to the primary calendar associated with grant.
    # @param request_body [Hash] The values to update the calendar with
    # @return [Array(Hash, String)] The updated calendar and API Request ID.
    def update(identifier:, calendar_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}",
        request_body: request_body
      )
    end

    # Deletes a calendar.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param calendar_id [String] The id of the calendar to delete.
    #   Use "primary" to refer to the primary calendar associated with grant.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, calendar_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}"
      )

      [true, request_id]
    end

    # Checks multiple calendars to find available time slots for a single meeting.
    #
    # @param request_body [Hash] Request body to pass to the request.
    # @return [Array(Hash, String)] Availability object and API request ID.
    def get_availability(request_body:)
      post(
        path: "#{api_uri}/v3/calendars/availability",
        request_body: request_body
      )
    end

    # Get the free/busy schedule for a list of email addresses.
    #
    # @param identifier [str] The identifier of the grant to act upon.
    # @param request_body [Hash] Request body to pass to the request.
    # @return [Array(Array(Hash), String)] The free/busy response.
    def get_free_busy(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/calendars/availability",
        request_body: request_body
      )
    end
  end
end
