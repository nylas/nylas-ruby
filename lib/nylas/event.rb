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
    has_n_of_attribute :notifications, :event_notification
    attribute :original_start_time, :unix_timestamp
    attribute :job_status_id, :string, read_only: true

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

    # Generate an ICS file server-side, from an Event
    # @param ics_options [ICSOptions] Optional configuration for the ICS file
    # @return [String] String for writing directly into an ICS file
    def generate_ics(ics_options = nil)
      raise ArgumentError, "Cannot generate an ICS file for an event without a Calendar ID or when set" unless
        calendar_id && self.when

      payload = build_generate_ics_request
      payload["ics_options"] = ics_options.to_h if ics_options
      response = api.execute(
        method: :post,
        path:  "#{resources_path}/to-ics",
        payload: JSON.dump(payload)
      )

      response[:ics]
    end

    private

    def build_generate_ics_request
      payload = {}
      if id
        payload[:event_id] = id
      else
        payload = to_h(enforce_read_only: true)
      end
      payload
    end

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
