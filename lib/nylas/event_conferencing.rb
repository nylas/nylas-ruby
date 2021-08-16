# frozen_string_literal: true

module Nylas
  # Structure to represent the Event Conferencing object
  # @see https://developer.nylas.com/docs/connectivity/calendar/conference-sync-beta
  class EventConferencing
    include Model::Attributable
    attribute :provider, :string
    attribute :details, :event_conferencing_details
    attribute :autocreate, :event_conferencing_autocreate
  end
end
