# frozen_string_literal: true

module Nylas
  # Additional methods for some of Calendar's other functionality
  # @see https://developer.nylas.com/docs/connectivity/calendar
  class CalendarCollection < Collection
    # Check multiple calendars to find available time slots for a single meeting
    # @param duration_minutes [Integer] The total number of minutes the event should last
    # @param interval_minutes [Integer] How many minutes it should check for availability
    # @param start_time [Integer] The timestamp for the beginning of the event
    # @param end_time [Integer] The timestamp for the end of the event
    # @param emails [Array<String>] Emails on the same domain to check
    # @param buffer [Integer] The amount of buffer time in minutes that you want around existing meetings
    # @param round_robin [String] Finds available meeting times in a round-robin style
    # @param event_collection_id [String] Unique identifier for a collection of events that are created
    # @param free_busy [Array<Nylas::FreeBusy>] A list of free-busy data for users not in your organization
    # @param open_hours [Array<Nylas::OpenHours>] Additional times email accounts are available
    # @param calendars [Array] Check account and calendar IDs for free/busy status
    # @return [Hash] The availability information; a list of time slots where all participants are available
    def availability(duration_minutes:,
                     interval_minutes:,
                     start_time:,
                     end_time:,
                     emails: [],
                     buffer: nil,
                     round_robin: nil,
                     event_collection_id: nil,
                     free_busy: [],
                     open_hours: [],
                     calendars: [])
      validate_calendars_or_emails(calendars, emails)
      validate_open_hours(emails, free_busy, open_hours) unless open_hours.empty?

      execute_availability("/calendars/availability",
                           duration_minutes: duration_minutes,
                           interval_minutes: interval_minutes,
                           start_time: start_time,
                           end_time: end_time,
                           emails: emails,
                           buffer: buffer,
                           round_robin: round_robin,
                           event_collection_id: event_collection_id,
                           free_busy: free_busy.map(&:to_h),
                           open_hours: open_hours.map(&:to_h),
                           calendars: calendars)
    end

    # Check multiple calendars to find availability for multiple meetings with several participants
    # @param duration_minutes [Integer] The total number of minutes the event should last
    # @param interval_minutes [Integer] How many minutes it should check for availability
    # @param start_time [Integer] The timestamp for the beginning of the event
    # @param end_time [Integer] The timestamp for the end of the event
    # @param emails [Array<Array<String>>] Emails on the same domain to check
    # @param buffer [Integer] The amount of buffer time in minutes that you want around existing meetings
    # @param free_busy [Array<Nylas::FreeBusy>] A list of free-busy data for users not in your organization
    # @param open_hours [Array<Nylas::OpenHours>] Additional times email accounts are available
    # @param calendars [Array] Check account and calendar IDs for free/busy status
    # @return [Hash] The availability information; a list of all possible groupings that share time slots
    def consecutive_availability(duration_minutes:,
                                 interval_minutes:,
                                 start_time:,
                                 end_time:,
                                 emails: [],
                                 buffer: nil,
                                 free_busy: [],
                                 open_hours: [],
                                 calendars: [])
      validate_calendars_or_emails(emails, calendars)
      validate_open_hours(emails, free_busy, open_hours) unless open_hours.empty?

      execute_availability("/calendars/availability/consecutive",
                           duration_minutes: duration_minutes,
                           interval_minutes: interval_minutes,
                           start_time: start_time,
                           end_time: end_time,
                           emails: emails,
                           buffer: buffer,
                           free_busy: free_busy.map(&:to_h),
                           open_hours: open_hours.map(&:to_h),
                           calendars: calendars)
    end

    private

    def execute_availability(path, **payload)
      api.execute(
        method: :post,
        path: path,
        payload: JSON.dump(payload)
      )
    end

    def validate_calendars_or_emails(calendars, emails)
      return unless calendars.empty? && emails.empty?

      raise ArgumentError, "You must provide at least one of 'emails' or 'calendars'"
    end

    def validate_open_hours(emails, free_busy, open_hours)
      raise TypeError, "open_hours' must be an array." unless open_hours.is_a?(Array)

      open_hours_emails = map_open_hours_emails(open_hours)
      free_busy_emails = map_free_busy_emails(free_busy)
      emails = merge_arrays(emails) if emails[0].is_a?(Array)

      open_hours_emails.each do |email|
        next if emails.include?(email) || free_busy_emails.include?(email)

        raise ArgumentError, "Open Hours cannot contain an email not present in the main email list or
the free busy email list."
      end
    end

    def map_open_hours_emails(open_hours)
      open_hours_emails = []
      open_hours.map do |oh|
        open_hours_emails += oh.emails
      end
      open_hours_emails
    end

    def map_free_busy_emails(free_busy)
      free_busy_emails = []
      free_busy.map do |fb|
        free_busy_emails.append(fb.email)
      end
      free_busy_emails
    end

    def merge_arrays(array)
      list = []
      array.each do |x|
        list += x
      end
      list
    end
  end
end
