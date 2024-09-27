# frozen_string_literal: true

module Nylas::V2
  # Additional methods for some of Scheduler's other functionality
  # @see https://developer.nylas.com/docs/api/scheduler#overview
  class SchedulerCollection < Collection
    # Retrieve Google availability
    # @return [Hash] Returns the availability
    def get_google_availability
      execute_provider_availability("google")
    end

    # Retrieve Office 365 availability
    # @return [Hash] Returns the availability
    def get_office_365_availability
      execute_provider_availability("o365")
    end

    # Retrieve public config for a scheduling page
    # @param slug [String] The Scheduler page slug
    # @return [Scheduler] Returns the Scheduler object representing the page configuration
    def get_page_slug(slug)
      page_response = api.execute(
        method: :get,
        path: "/schedule/#{slug}/info"
      )

      Scheduler.new(**page_response.merge(api: api))
    end

    # Retrieve available time slots
    # @param slug [String] The Scheduler page slug
    # @return [Array<SchedulerTimeSlot>] Returns the list of available timeslots
    def get_available_time_slots(slug)
      response = api.execute(
        method: :get,
        path: "/schedule/#{slug}/timeslots"
      )

      timeslots = []
      response.each do |available_slot|
        timeslots.push(SchedulerTimeSlot.new(**available_slot.merge(api: api)))
      end
      timeslots
    end

    # Book a time slot
    # @param slug [String] The Scheduler page slug
    # @param timeslot [SchedulerBookingRequest] The time slot booking request
    # @return [SchedulerBookingConfirmation] Returns the booking confirmation
    def book_time_slot(slug, timeslot)
      payload = timeslot.to_h
      # The booking endpoint requires additional_values and additional_emails
      # to exist regardless if they are empty or not
      payload[:additional_values] = {} unless payload[:additional_values]
      payload[:additional_emails] = [] unless payload[:additional_emails]
      booking_response = api.execute(
        method: :post,
        path: "/schedule/#{slug}/timeslots",
        payload: JSON.dump(payload)
      )

      SchedulerBookingConfirmation.new(**booking_response.merge(api: api))
    end

    # Cancel a booking
    # @param slug [String] The Scheduler page slug
    # @param edit_hash [String] The token used for editing the booked time slot
    # @param reason [String] The reason for cancelling the booking
    # @return [Hash] Returns a hash of a boolean representing success of cancellation
    def cancel_booking(slug, edit_hash, reason)
      api.execute(
        method: :post,
        path: "/schedule/#{slug}/#{edit_hash}/cancel",
        payload: JSON.dump(reason: reason)
      )
    end

    # Confirm a booking
    # @param slug [String] The Scheduler page slug
    # @param edit_hash [String] The token used for editing the booked time slot
    # @return [SchedulerBookingConfirmation] Returns the confirmed booking confirmation
    def confirm_booking(slug, edit_hash)
      booking_response = api.execute(
        method: :post,
        path: "/schedule/#{slug}/#{edit_hash}/confirm",
        payload: {}
      )

      SchedulerBookingConfirmation.new(**booking_response.merge(api: api))
    end

    private

    # Retrieve provider availability
    # @return [Hash] Returns the availability
    def execute_provider_availability(provider)
      api.execute(
        method: :get,
        path: "/schedule/availability/#{provider}"
      )
    end
  end
end
