# frozen_string_literal: true

module Nylas
  # Ruby representation of a Nylas Outbox Job Status object
  # @see https://developer.nylas.com/docs/api/#post/v2/outbox
  class OutboxJobStatus
    include Model::Attributable

    attribute :job_status_id, :string
    attribute :account_id, :string
    attribute :status, :string
    attribute :original_data, :outbox_message
  end
end

