# frozen_string_literal: true

module Nylas
  # Structure to represent a the Event Schema.
  # @see https://docs.nylas.com/reference#events
  class Event
    include Model
    self.resources_path = "/events"
    self.creatable = true
    self.listable = true
    self.showable = true
    self.filterable = true
    self.updatable = true
    self.destroyable = true
    self.id_listable = true
    self.countable = true

    attribute :id, :string, read_only: true
    attribute :object, :string, read_only: true
    attribute :account_id, :string, read_only: true
    attribute :calendar_id, :string
    attribute :master_event_id, :string
    attribute :message_id, :string
    attribute :ical_uid, :string
    attribute :event_collection_id, :string

    attribute :capacity, :integer
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
    has_n_of_attribute :round_robin_order, :string
    attribute :original_start_time, :unix_timestamp
    attribute :reminder_minutes, :string
    attribute :reminder_method, :string
    attribute :job_status_id, :string, read_only: true

    attr_accessor :notify_participants

    def busy?
      busy
    end

    def read_only?
      read_only
    end

    def save
      validate
      format_reminder_minutes

      super
    end

    def rsvp(status, notify_participants:)
      rsvp = Rsvp.new(api: api, status: status, notify_participants: notify_participants,
                      event_id: id, account_id: account_id)
      rsvp.save
    end

    # Generate an ICS file server-side, from an Event
    # @param ical_uid [String] Unique identifier used events across calendaring systems
    # @param method [String] Description of invitation and response methods for attendees
    # @param prodid [String] Company-specific unique product identifier
    # @return [String] String for writing directly into an ICS file
    def generate_ics(ical_uid: nil, method: nil, prodid: nil)
      raise ArgumentError, "Cannot generate an ICS file for an event without a Calendar ID or when set" unless
        calendar_id && self.when

      payload = build_ics_event_payload(ical_uid, method, prodid)
      response = api.execute(
        method: :post,
        path: "#{resources_path}/to-ics",
        payload: JSON.dump(payload)
      )

      response[:ics]
    end

    private

    def validate
      if conferencing
        body = to_h
        if body.dig(:conferencing, :details) && body.dig(:conferencing, :autocreate)
          raise ArgumentError, "Cannot set both 'details' and 'autocreate' in conferencing object."
        end
      end
      return unless capacity && capacity != -1 && participants && participants.length > capacity

      raise ArgumentError, "The number of participants in the event exceeds the set capacity."
    end

    def build_ics_event_payload(ical_uid, method, prodid)
      payload = {}
      if id
        payload[:event_id] = id
      else
        payload = to_h(enforce_read_only: true)
      end
      ics_options = build_ics_options_payload(ical_uid, method, prodid)
      payload["ics_options"] = ics_options unless ics_options.empty?
      payload
    end

    def build_ics_options_payload(ical_uid, method, prodid)
      payload = {}
      payload["ical_uid"] = ical_uid if ical_uid
      payload["method"] = method if method
      payload["prodid"] = prodid if prodid
      payload
    end

    # Formats the reminder minute field to match the API format: "[%d]"
    def format_reminder_minutes
      return if reminder_minutes.nil? || reminder_minutes.empty? || reminder_minutes.match(/\[\d+\]/)

      self.reminder_minutes = "[#{reminder_minutes}]"
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
