# frozen_string_literal: true

module Nylas
  # Ruby representation of a Nylas Outbox Job Status object
  # @see https://developer.nylas.com/docs/api/#post/v2/outbox
  class OutboxJobStatus < JobStatus
    include Model

    attribute :send_at, :unix_timestamp
    attribute :original_send_at, :unix_timestamp
    attribute :message_id, :string
    attribute :thread_id, :string
    attribute :original_data, :outbox_message

    transfer :api, to: %i[original_data]

    inherit_attributes
  end
end

