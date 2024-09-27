# frozen_string_literal: true

module Nylas::V2
  # Configuration settings for a Scheduler page
  # @see https://developer.nylas.com/docs/api/scheduler
  class SchedulerConfig
    include Model::Attributable

    attribute :appearance, :hash
    attribute :booking, :hash
    attribute :calendar_ids, :hash
    attribute :event, :hash
    attribute :expire_after, :hash
    attribute :locale, :string
    attribute :locale_for_guests, :string
    attribute :timezone, :string

    has_n_of_attribute :reminders, :hash
  end
end
