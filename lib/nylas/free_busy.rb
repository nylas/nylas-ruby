# frozen_string_literal: true

module Nylas
  # Query free/busy information for a calendar during a certain time period
  # @see https://docs.nylas.com/reference#calendars-free-busy
  class FreeBusy
    attr_accessor :start_time, :end_time, :api

    def initialize(api:)
      self.api = api
    end

    def fetch(emails:, start_time:, end_time:)
      data = {
        emails: emails,
        start_time: start_time,
        end_time: end_time
      }
      api.execute(
        method: :post,
        path: "/calendars/free-busy",
        payload: JSON.dump(data)
      )
    end
  end
end
