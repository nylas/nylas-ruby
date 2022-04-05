# frozen_string_literal: true

module Nylas
  # Ruby representation of a Nylas Outbox Message object
  # @see https://developer.nylas.com/docs/api/#post/v2/outbox
  class OutboxMessage < Draft
    include Model

    attribute :send_at, :unix_timestamp
    attribute :retry_limit_datetime, :unix_timestamp
    attribute :original_send_at, :unix_timestamp, read_only: true

    transfer :api, to: %i[events files folder labels]

    inherit_attributes
  end
end
