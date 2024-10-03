# frozen_string_literal: true

require_relative "resource"
require_relative "bookings"
require_relative "availability"
require_relative "configurations"
require_relative "sessions"

module Nylas
  # Nylas Scheduling API
  class Scheduling < Resource
    attr_reader :confiugrations, :bookings, :sessions, :availability

    # Initializes the scheduling resource.
    # @param sdk_instance [Nylas::API] The API instance to which the resource is bound.
    def initialize(sdk_instance)
      super(sdk_instance)
      @configurations = Configurations.new(sdk_instance)
      @bookings = Bookings.new(sdk_instance)
      @sessions = Sessions.new(sdk_instance)
      @availability = Availability.new(sdk_instance)
    end
  end
end
