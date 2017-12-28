module Nylas
  # Structure to represent a the Event Schema.
  # @see https://docs.nylas.com/reference#events
  class Event
    include Model::Attributable
    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    attribute :calendar_id, :string
    attribute :message_id, :string

    attribute :busy, :boolean
    attribute :description, :string
    attribute :owner, :string
    has_n_of_attribute :participants, :participant
    attribute :read_only, :boolean
    attribute :status, :string
    attribute :title, :string
    attribute :when, :timespan

    def busy?
      busy
    end

    def read_only?
      read_only
    end
  end
end
