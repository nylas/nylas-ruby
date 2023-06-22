# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  # Calendars
  class Calendars < BaseResource
    include Operations::Create
    include Operations::Update
    include Operations::List
    include Operations::Destroy
    include Operations::Find

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
  end
end
