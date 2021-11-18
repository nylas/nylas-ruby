# frozen_string_literal: true

require "spec_helper"

describe Nylas::SchedulerCollection do
  describe "ProviderAvailability" do
    it "(getGoogleAvailability) should call the correct endpoint" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

      scheduler_collection.get_google_availability

      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/schedule/availability/google"
      )
    end

    it "(getOffice365Availability) should call the correct endpoint" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

      scheduler_collection.get_office_365_availability

      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/schedule/availability/o365"
      )
    end
  end

  describe "Public Booking API" do
    it "(getPageBySlug) should return a Scheduler type" do
      scheduler_json = {
        app_client_id: "test-client-id",
        app_organization_id: 0,
        config: {
          timezone: "America/Los_Angeles",
        },
        edit_token: "token",
        name: "Test",
        slug: "test-slug",
        created_at: "2021-06-24",
        modified_at: "2021-06-24"
      }
      api = instance_double(Nylas::API, execute: scheduler_json)
      scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

      scheduler = scheduler_collection.get_page_slug("test-slug")

      expect(scheduler.app_client_id).to eql("test-client-id")
      expect(scheduler.app_organization_id).to be(0)
      expect(scheduler.config.timezone).to eql("America/Los_Angeles")
      expect(scheduler.edit_token).to eql("token")
      expect(scheduler.name).to eql("Test")
      expect(scheduler.slug).to eql("test-slug")
      expect(scheduler.created_at).to eql(Date.parse("2021-06-24"))
      expect(scheduler.modified_at).to eql(Date.parse("2021-06-24"))
      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/schedule/test-slug/info"
      )
    end

    it "(getAvailableTimeSlots) should return an array of SchedulerTimeSlot" do
      scheduler_time_slots = [
        {
          account_id: "test-account-id",
          calendar_id: "test-calendar-id",
          emails: ["test@example.com"],
          end: 1636731958,
          host_name: "www.hostname.com",
          start: 1636728347
        }
      ]
      api = instance_double(Nylas::API, execute: scheduler_time_slots)
      scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

      timeslots = scheduler_collection.get_available_time_slots("test-slug")

      expect(timeslots.length).to be(1)
      expect(timeslots[0].account_id).to eql("test-account-id")
      expect(timeslots[0].calendar_id).to eql("test-calendar-id")
      expect(timeslots[0].emails[0]).to eql("test@example.com")
      expect(timeslots[0].host_name).to eql("www.hostname.com")
      expect(timeslots[0].end).to eql(Time.at(1636731958))
      expect(timeslots[0].start).to eql(Time.at(1636728347))
      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/schedule/test-slug/timeslots"
      )
    end

    it "cancel booking" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

      scheduler_collection.cancel_booking("test-slug", "test-edit-hash", "test")

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/schedule/test-slug/test-edit-hash/cancel",
        payload: JSON.dump(reason: "test")
      )
    end

    describe "SchedulerBookingConfirmation" do
      it "(bookTimeSlot) should return a SchedulerBookingConfirmation type" do
        booking_confirmation = {
          account_id: "test-account-id",
          additional_field_values: {
            test: "yes"
          },
          calendar_event_id: "test-event-id",
          calendar_id: "test-calendar-id",
          edit_hash: "test-edit-hash",
          end_time: 1636731958,
          id: 123,
          is_confirmed: false,
          location: "Earth",
          recipient_email: "recipient@example.com",
          recipient_locale: "en_US",
          recipient_name: "Recipient Doe",
          recipient_tz: "America/New_York",
          start_time: 1636728347,
          title: "Test Booking"
        }
        api = instance_double(Nylas::API, execute: booking_confirmation)
        scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

        slot = Nylas::SchedulerTimeSlot.new(
          account_id: "test-account-id",
          calendar_id: "test-calendar-id",
          emails: ["recipient@example.com"],
          start: Time.at(1636728347),
          end: Time.at(1636731958)
        )
        timeslot_to_book = Nylas::SchedulerBookingRequest.new(
          additional_values: {
            test: "yes"
          },
          email: "recipient@example.com",
          locale: "en_US",
          name: "Recipient Doe",
          timezone: "America/New_York",
          slot: slot
        )
        booking_confirmation = scheduler_collection.book_time_slot("test-slug", timeslot_to_book)

        expect(booking_confirmation.account_id).to eql("test-account-id")
        expect(booking_confirmation.calendar_id).to eql("test-calendar-id")
        expect(booking_confirmation.additional_field_values).to eql(test: "yes")
        expect(booking_confirmation.calendar_event_id).to eql("test-event-id")
        expect(booking_confirmation.calendar_id).to eql("test-calendar-id")
        expect(booking_confirmation.calendar_event_id).to eql("test-event-id")
        expect(booking_confirmation.edit_hash).to eql("test-edit-hash")
        expect(booking_confirmation.id).to be(123)
        expect(booking_confirmation.is_confirmed).to be(false)
        expect(booking_confirmation.location).to eql("Earth")
        expect(booking_confirmation.title).to eql("Test Booking")
        expect(booking_confirmation.recipient_email).to eql("recipient@example.com")
        expect(booking_confirmation.recipient_locale).to eql("en_US")
        expect(booking_confirmation.recipient_name).to eql("Recipient Doe")
        expect(booking_confirmation.recipient_tz).to eql("America/New_York")
        expect(booking_confirmation.end_time).to eql(Time.at(1636731958))
        expect(booking_confirmation.start_time).to eql(Time.at(1636728347))
        expect(api).to have_received(:execute).with(
          method: :post,
          path: "/schedule/test-slug/timeslots",
          payload: JSON.dump(
            additional_values: {
              test: "yes"
            },
            email: "recipient@example.com",
            locale: "en_US",
            name: "Recipient Doe",
            timezone: "America/New_York",
            slot: {
              account_id: "test-account-id",
              calendar_id: "test-calendar-id",
              start: 1636728347,
              end: 1636731958,
              emails: ["recipient@example.com"]
            }
          )
        )
      end

      it "(confirmBooking) should return a SchedulerBookingConfirmation type" do
        booking_confirmation = {
          account_id: "test-account-id",
          additional_field_values: {
            test: "yes"
          },
          calendar_event_id: "test-event-id",
          calendar_id: "test-calendar-id",
          edit_hash: "test-edit-hash",
          end_time: 1636731958,
          id: 123,
          is_confirmed: true,
          location: "Earth",
          recipient_email: "recipient@example.com",
          recipient_locale: "en_US",
          recipient_name: "Recipient Doe",
          recipient_tz: "America/New_York",
          start_time: 1636728347,
          title: "Test Booking"
        }
        api = instance_double(Nylas::API, execute: booking_confirmation)
        scheduler_collection = described_class.new(model: Nylas::Scheduler, api: api)

        booking_confirmation = scheduler_collection.confirm_booking("test-slug", "test-edit-hash")

        expect(booking_confirmation.account_id).to eql("test-account-id")
        expect(booking_confirmation.calendar_id).to eql("test-calendar-id")
        expect(booking_confirmation.additional_field_values).to eql(test: "yes")
        expect(booking_confirmation.calendar_event_id).to eql("test-event-id")
        expect(booking_confirmation.calendar_id).to eql("test-calendar-id")
        expect(booking_confirmation.calendar_event_id).to eql("test-event-id")
        expect(booking_confirmation.edit_hash).to eql("test-edit-hash")
        expect(booking_confirmation.id).to be(123)
        expect(booking_confirmation.is_confirmed).to be(true)
        expect(booking_confirmation.location).to eql("Earth")
        expect(booking_confirmation.title).to eql("Test Booking")
        expect(booking_confirmation.recipient_email).to eql("recipient@example.com")
        expect(booking_confirmation.recipient_locale).to eql("en_US")
        expect(booking_confirmation.recipient_name).to eql("Recipient Doe")
        expect(booking_confirmation.recipient_tz).to eql("America/New_York")
        expect(booking_confirmation.end_time).to eql(Time.at(1636731958))
        expect(booking_confirmation.start_time).to eql(Time.at(1636728347))
        expect(api).to have_received(:execute).with(
          method: :post,
          path: "/schedule/test-slug/test-edit-hash/confirm",
          payload: {}
        )
      end
    end
  end
end
