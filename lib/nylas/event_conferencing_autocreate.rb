# frozen_string_literal: true

module Nylas
  # Structure to represent the autocreate object within the Event Conferencing object
  # @see https://developer.nylas.com/docs/connectivity/calendar/conference-sync-beta
  class EventConferencingAutocreate
    include Model::Attributable
    attribute :settings, :hash, default: {}
  end
end
