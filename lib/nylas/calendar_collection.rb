# frozen_string_literal: true

module Nylas
  # Additional methods for some of Calendar's other functionality
  # @see https://developer.nylas.com/docs/connectivity/calendar
  class CalendarCollection < Collection
    def availability(duration_minutes:,
                     interval_minutes:,
                     start_time:,
                     end_time:,
                     emails:,
                     buffer: nil,
                     round_robin: nil,
                     free_busy: [],
                     open_hours: [])
      validate_open_hours(emails, free_busy, open_hours) unless open_hours.empty?

      execute_availability("/calendars/availability",
                           duration_minutes: duration_minutes,
                           interval_minutes: interval_minutes,
                           start_time: start_time,
                           end_time: end_time,
                           emails: emails,
                           buffer: buffer,
                           round_robin: round_robin,
                           free_busy: free_busy,
                           open_hours: open_hours)
    end

    def consecutive_availability(duration_minutes:,
                                 interval_minutes:,
                                 start_time:,
                                 end_time:,
                                 emails:,
                                 buffer: nil,
                                 free_busy: [],
                                 open_hours: [])
      validate_open_hours(emails, free_busy, open_hours) unless open_hours.empty?

      execute_availability("/calendars/availability/consecutive",
                           duration_minutes: duration_minutes,
                           interval_minutes: interval_minutes,
                           start_time: start_time,
                           end_time: end_time,
                           emails: emails,
                           buffer: buffer,
                           free_busy: free_busy,
                           open_hours: open_hours)
    end

    private

    def execute_availability(path, **payload)
      api.execute(
        method: :post,
        path: path,
        payload: JSON.dump(payload)
      )
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
