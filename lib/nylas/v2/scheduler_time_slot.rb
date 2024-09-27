# frozen_string_literal: true

module Nylas::V2
  # Structure to represent the time slot object from the Scheduler API
  class SchedulerTimeSlot
    include Model::Attributable
    attribute :account_id, :string
    attribute :calendar_id, :string
    attribute :host_name, :string
    attribute :start, :unix_timestamp
    attribute :end, :unix_timestamp
    has_n_of_attribute :emails, :string
  end
end
