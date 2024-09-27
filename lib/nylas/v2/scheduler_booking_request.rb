# frozen_string_literal: true

module Nylas::V2
  # Structure to represent the booking request used for the Scheduler API
  class SchedulerBookingRequest
    include Model::Attributable
    attribute :additional_values, :hash
    attribute :email, :string
    attribute :locale, :string
    attribute :name, :string
    attribute :page_hostname, :string
    attribute :replaces_booking_hash, :string
    attribute :timezone, :string
    attribute :slot, :scheduler_time_slot
    has_n_of_attribute :additional_emails, :string
  end
end
