# frozen_string_literal: true

module Nylas
  # Additional times email accounts are available
  # @see https://developer.nylas.com/docs/api/#post/calendars/availability
  class OpenHours
    include Model::Attributable

    attribute :timezone, :string
    attribute :start, :string
    attribute :end, :string
    has_n_of_attribute :emails, :string
    has_n_of_attribute :days, :integer
  end
end
