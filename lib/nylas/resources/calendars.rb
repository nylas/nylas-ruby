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
    # @param request_body [Hash, nil] Request body to pass to the request.
    # @return [Array(Hash, String)] Availability object and API request ID.
    def get_availability(request_body: nil)
      post(
        path: "#{api_uri}/v3/calendars/availability",
        request_body: request_body
      )
    end
  end
end
