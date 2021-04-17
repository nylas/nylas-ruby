# frozen_string_literal: true

module Nylas
  # Query free/busy information for a calendar during a certain time period
  # @see https://docs.nylas.com/reference#calendars-free-busy
  class FreeBusy
    include Model::Attributable

    attribute :email, :string
    attribute :object, :string
    has_n_of_attribute :time_slots, :time_slot
  end
end
