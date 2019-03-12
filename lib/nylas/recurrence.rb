# frozen_string_literal: true

module Nylas
  # Representation of a Recurrence object
  # @see https://docs.nylas.com/reference#section-recurrence
  class Recurrence
    include Model::Attributable
    has_n_of_attribute :rrule, :string
    attribute :timezone, :string
  end
end
