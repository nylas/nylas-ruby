# frozen_string_literal: true

module Nylas::V2
  # Structure to represent the details object within the Event Conferencing object
  # @see https://developer.nylas.com/docs/connectivity/calendar/conference-sync-beta
  class EventConferencingDetails
    include Model::Attributable
    attribute :meeting_code, :string
    attribute :password, :string
    attribute :pin, :string
    attribute :url, :string
    has_n_of_attribute :phone, :string
  end
end
