module Nylas
  # Structure to represent a the Event Schema.
  # @see https://docs.nylas.com/reference#events
  class Event
    include Model
    self.resources_path = "/events"
    allows_operations(creatable: true, listable: true, filterable: true, showable: true, updatable: true,
                      destroyable: true)

    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    attribute :calendar_id, :string
    attribute :master_event_id, :string
    attribute :message_id, :string

    attribute :busy, :boolean
    attribute :description, :string
    attribute :location, :string
    attribute :owner, :string
    attribute :recurrence, :recurrence
    has_n_of_attribute :participants, :participant
    attribute :read_only, :boolean
    attribute :status, :string
    attribute :title, :string
    attribute :when, :timespan
    attribute :original_start_time, :unix_timestamp
    attr_reader :raw_json

    def initialize(*args, &block)
      super(*args, &block)
      @raw_json = JSON.parse(to_json)
    end

    def busy?
      busy
    end

    def read_only?
      read_only
    end

    def save
      result = if persisted?
                 raise ModelNotUpdatableError, self unless updatable?

                 payload = JSON.parse(attributes.serialize)
                 payload["when"] = payload["when"].except("object")
                 execute(method: :put, payload: payload.to_json, path: resource_path)
               else
                 create
               end
      attributes.merge(result)
    end

    def rsvp(status, notify_participants:)
      rsvp = Rsvp.new(api: api, status: status, notify_participants: notify_participants,
                      event_id: id, account_id: account_id)
      rsvp.save
    end
  end
end
