# frozen_string_literal: true

module Nylas
  # Allows RSVPing to a particular event
  # @see https://docs.nylas.com/reference#rsvping-to-invitations
  class Rsvp
    include Model
    self.creatable = true

    attribute :account_id, :string
    attribute :event_id, :string
    attribute :status, :string
    attr_accessor :notify_participants

    def save
      api.execute(
        method: :post,
        path: "/send-rsvp",
        payload: attributes.serialize_for_api,
        query: { notify_participants: notify_participants }
      )
    end
  end
end
