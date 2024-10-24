# frozen_string_literal: true

require_relative "./configurations"
require_relative "./sessions"
require_relative "./bookings"
require_relative "./availability"

module Nylas
  # Nylas Scheduler API
  # This class provides access to the Scheduler resources, including
  # configurations, bookings, sessions, and availability.
  #
  # @attr_reader [Nylas::Configurations] configurations The Scheduler configurations resource for your Nylas application.
  # @attr_reader [Nylas::Bookings] bookings The Scheduler bookings resource for your Nylas application.
  # @attr_reader [Nylas::Sessions] sessions The Scheduler sessions resource for your Nylas application.
  # @attr_reader [Nylas::Availability] availability The Scheduler availability resource for your Nylas application.
  class Scheduler
    attr_reader :configurations, :sessions, :bookings, :availability

    # Initializes the Scheduler class.
    #
    # @param api_client [APIClient] The Nylas API client instance for making requests.
    def initialize(api_client)
      @api_client = api_client
      @configurations = Configurations.new(@api_client)
      @bookings = Bookings.new(@api_client)
      @sessions = Sessions.new(@api_client)
      @availability = Availability.new(@api_client)
    end
  end
end
