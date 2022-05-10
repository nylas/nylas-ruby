# frozen_string_literal: true

module Nylas
  # Capacity values for a timeslot
  # @see https://docs.nylas.com/reference#calendars-free-busy
  class TimeSlotCapacity
    include Model::Attributable

    attribute :event_id, :string
    attribute :current_capacity, :integer
    attribute :max_capacity, :integer
  end
end

