# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/grants_api_operations"

module Nylas
  # Calendars
  class Calendars < Resource
    include GrantsApiOperations::Create
    include GrantsApiOperations::Update
    include GrantsApiOperations::List
    include GrantsApiOperations::Destroy
    include GrantsApiOperations::Find

    # Initializes Calendars.
    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end

    # Checks multiple calendars to find available time slots for a single meeting.
    #
    # @param request_body Hash Request body to pass to the request.
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
