# frozen_string_literal: true

module Nylas
  # Structure to represent a the Event Schema.
  # @see https://docs.nylas.com/reference#events
  class Event
    include Model
    self.resources_path = "/events"
    allows_operations(creatable: true, listable: true, filterable: true, showable: true, updatable: true,
                      destroyable: true)

    attribute :id, :string, read_only: true
    attribute :object, :string, read_only: true
    attribute :account_id, :string, read_only: true
    attribute :calendar_id, :string
    attribute :master_event_id, :string
    attribute :message_id, :string
    attribute :ical_uid, :string

    attribute :busy, :boolean
    attribute :description, :string
    attribute :location, :string
    attribute :owner, :string
    attribute :recurrence, :recurrence
    has_n_of_attribute :participants, :participant
    attribute :read_only, :boolean
    attribute :status, :string
    attribute :title, :string
    attribute :when, :when
    attribute :metadata, :hash
    attribute :conferencing, :event_conferencing
    attribute :original_start_time, :unix_timestamp

    attr_accessor :notify_participants

    def busy?
      busy
    end

    def read_only?
      read_only
    end

    def save
      if conferencing
        body = to_h
        if body.dig(:conferencing, :details) && body.dig(:conferencing, :autocreate)
          raise ArgumentError, "Cannot set both 'details' and 'autocreate' in conferencing object."
        end
      end

      super
    end

    def rsvp(status, notify_participants:)
      rsvp = Rsvp.new(api: api, status: status, notify_participants: notify_participants,
                      event_id: id, account_id: account_id)
      rsvp.save
    end

    private

    def query_params
      if notify_participants.nil?
        {}
      else
        {
          notify_participants: notify_participants
        }
      end
    end
  end
end
