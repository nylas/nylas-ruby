# frozen_string_literal: true

module Nylas
  # Structure to represent the booking response returned from the Scheduler API
  class SchedulerBookingConfirmation
    include Model::Attributable
    attribute :id, :integer
    attribute :account_id, :string
    attribute :calendar_event_id, :string
    attribute :calendar_id, :string
    attribute :edit_hash, :string
    attribute :location, :string
    attribute :title, :string
    attribute :recipient_email, :string
    attribute :recipient_locale, :string
    attribute :recipient_name, :string
    attribute :recipient_tz, :string
    attribute :additional_field_values, :hash
    attribute :is_confirmed, :boolean
    attribute :start_time, :unix_timestamp
    attribute :end_time, :unix_timestamp
    has_n_of_attribute :additional_emails, :string
  end
end
