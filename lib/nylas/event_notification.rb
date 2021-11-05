# frozen_string_literal: true

module Nylas
  # Structure to represent the Event Notification object
  # @see https://developer.nylas.com/docs/connectivity/calendar/event-notifications
  class EventNotification
    include Model::Attributable

    attribute :type, :string
    attribute :minutes_before_event, :integer
    attribute :url, :string
    attribute :payload, :string
    attribute :subject, :string
    attribute :body, :string
    attribute :message, :string
  end
end
