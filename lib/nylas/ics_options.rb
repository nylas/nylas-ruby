# frozen_string_literal: true

module Nylas
  # Optional configuration for the ICS file
  # @see https://developer.nylas.com/docs/api/#post/events/to-ics
  class ICSOptions
    include Model::Attributable

    attribute :ical_uid, :string
    attribute :method, :string
    attribute :prodid, :string
  end
end
