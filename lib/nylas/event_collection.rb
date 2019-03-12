# frozen_string_literal: true

module Nylas
  # Syntactical sugar methods for some of the Event's filters
  # @see https://docs.nylas.com/reference#get-events
  class EventCollection < Collection
    def expand_recurring
      where(expand_recurring: true)
    end

    def show_cancelled
      where(show_cancelled: true)
    end
  end
end
