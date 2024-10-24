# frozen_string_literal: true

require_relative "./configurations"
require_relative "./sessions"
require_relative "./bookings"
require_relative "./availability"

module Nylas
  class Scheduler
    def initialize(api_client)
      @api_client = api_client
      @configurations = Configurations.new(@api_client)
      @bookings = Bookings.new(@api_client)
      @sessions = Sessions.new(@api_client)
      @availability = Availability.new(@api_client)
    end

    # The configuration resources for your Nylas application.
    # @return [Nylas::Scheduler::Confiugrations] Scheduler configuration resources
    # for your Nylas application.
    def configurations
      @configurations
    end

    # The Session resources for your Nylas application.
    # @return [Nylas::Scheduler::Sessions] Scheduler session resources for your Nylas application.
    def sessions
      @sessions
    end
    
    # The Booking resources for your Nylas application.
    # @return [Nylas::Scheduler::Bookings] Scheduler booking resources for your Nylas application.
    def bookings
      @bookings
    end

    # The availability resources for your Nylas application.
    # @return [Nylas::Scheduler::Availability] Scheduling availability resources for your Nylas application.
    def availability
      @availability
    end
  end
end
