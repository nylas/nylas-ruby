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

    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end

    # Check multiple calendars to find available time slots for a single meeting
    # @param path_params [Hash] The path params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The availability object and API Request ID
    def get_availability(path_params: {}, request_body: nil)
      post(
        path: "#{host}/grants/#{path_params[:grant_id]}/calendars/availability",
        request_body: request_body
      )
    end
  end
end
