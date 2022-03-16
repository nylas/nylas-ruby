# frozen_string_literal: true

require "spec_helper"

describe Nylas::CalendarCollection do
  describe "availability" do
    it "makes a request to get single availability" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: Nylas::Calendar, api: api)
      free_busy = Nylas::FreeBusy.new(
        email: "swag@nylas.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = Nylas::OpenHours.new(
        emails: ["swag@nylas.com"],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      calendar_collection.availability(
        duration_minutes: 30,
        interval: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: ["swag@nylas.com"],
        buffer: 5,
        round_robin: "max-fairness",
        free_busy: [free_busy],
        open_hours: [open_hours]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability",
        payload: JSON.dump(
          duration_minutes: 30,
          interval: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: ["swag@nylas.com"],
          buffer: 5,
          round_robin: "max-fairness",
          free_busy: [free_busy],
          open_hours: [open_hours],
          calendars: []
        )
      )
    end

    it "makes a request to get multiple availability" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: Nylas::Calendar, api: api)
      free_busy = Nylas::FreeBusy.new(
        email: "swag@nylas.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = Nylas::OpenHours.new(
        emails: %w[one@example.com two@example.com three@example.com swag@nylas.com],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      calendar_collection.consecutive_availability(
        duration_minutes: 30,
        interval: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        emails: [["one@example.com"], %w[two@example.com three@example.com]],
        buffer: 5,
        free_busy: [free_busy],
        open_hours: [open_hours]
      )

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/calendars/availability/consecutive",
        payload: JSON.dump(
          duration_minutes: 30,
          interval: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: [["one@example.com"], %w[two@example.com three@example.com]],
          buffer: 5,
          free_busy: [free_busy],
          open_hours: [open_hours],
          calendars: []
        )
      )
    end
  end

  describe "verification" do
    it "throws an error if an email does not exist in open hours" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))

      calendar_collection = described_class.new(model: Nylas::Calendar, api: api)
      free_busy = Nylas::FreeBusy.new(
        email: "one@example.com",
        time_slots: [
          {
            object: "time_slot",
            status: "busy",
            start_time: 1_609_439_400,
            end_time: 1_640_975_400
          }
        ]
      )
      open_hours = Nylas::OpenHours.new(
        emails: %w[one@example.com two@example.com three@example.com swag@nylas.com],
        days: [0],
        timezone: "America/Chicago",
        start: "10:00",
        end: "14:00"
      )

      expect do
        calendar_collection.consecutive_availability(
          duration_minutes: 30,
          interval: 5,
          start_time: 1590454800,
          end_time: 1590780800,
          emails: [["one@example.com"], %w[two@example.com three@example.com]],
          buffer: 5,
          free_busy: [free_busy],
          open_hours: [open_hours],
          calendars: []
        )
      end.to raise_error(ArgumentError)
    end
  end

  it "throws an error if at least one of 'emails' or 'calendars' is not provided" do
    api = instance_double(Nylas::API, execute: JSON.parse("{}"))
    calendar_collection = described_class.new(model: Nylas::Calendar, api: api)

    expect do
      calendar_collection.consecutive_availability(
        duration_minutes: 30,
        interval: 5,
        start_time: 1590454800,
        end_time: 1590780800,
        buffer: 5,
      )
    end.to raise_error(ArgumentError)
  end
end
