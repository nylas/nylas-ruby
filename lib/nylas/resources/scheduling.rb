# frozen_string_literal: true

require_relative "resource"
require_relative "bookings"
require_relative "availability"
require_relative "configurations"
require_relative "sessions"

module Nylas
  # Nylas Scheduling API
  class Scheduling < Resource
    # The configuration resources for your Nylas application.
    #
    # @return [Nylas::Scheduling::Confiugrations] Scheduling configuration resources
    # for your Nylas application.
    def configurations
      Configurations.new(self)
    end

    # The Booking resources for your Nylas application.
    #
    # @return [Nylas::Scheduling::Bookings] Scheduling booking resources for your Nylas application.
    def bookings
      Bookings.new(self)
    end

    # The Session resources for your Nylas application.
    #
    # @return [Nylas::Scheduling::Sessions] Scheduling session resources for your Nylas application.
    def sessions
      Sessions.new(self)
    end

    # The availability resources for your Nylas application.
    #
    # @return [Nylas::Scheduling::Availability] Scheduling availability resources for your Nylas application.
    def availability
      Availability.new(self)
    end
  end
end
