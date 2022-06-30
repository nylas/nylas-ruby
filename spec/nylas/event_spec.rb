# frozen_string_literal: true

describe Nylas::Event do
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API)
      data = {
        id: "event-8766",
        object: "event",
        account_id: "acc-1234",
        busy: true,
        calendar_id: "cal-0987",
        description: "an event",
        message_id: "mess-8766",
        owner: '"owner" <owner@example.com>',
        participants: [
          {
            comment: "Let me think on it",
            phone_number: "+14160000000",
            email: "participant@example.com",
            name: "Participant",
            status: "noreply"
          },
          {
            comment: nil,
            email: "owner@example.com",
            name: "Owner",
            status: "yes"
          }
        ],
        read_only: true,
        status: "confirmed",
        title: "An Event",
        when: {
          end_time: 1_511_306_400,
          object: "timespan",
          start_time: 1_511_303_400
        },
        metadata: {
          event_type: "gathering"
        },
        conferencing: {
          provider: "Zoom Meeting",
          details: {
            url: "https://us02web.zoom.us/j/****************",
            meeting_code: "213",
            password: "xyz",
            phone: [
              "+11234567890"
            ]
          }
        },
        notifications: [{
          type: "email",
          minutes_before_event: "60",
          subject: "Test Event Notification",
          body: "Reminding you about our meeting."
        }]
      }

      event = described_class.from_json(JSON.dump(data), api: api)

      expect(event.id).to eql "event-8766"
      expect(event.account_id).to eql "acc-1234"
      expect(event.object).to eql "event"
      expect(event.account_id).to eql "acc-1234"
      expect(event.api).to be api
      expect(event).to be_busy
      expect(event.calendar_id).to eql "cal-0987"
      expect(event.description).to eql "an event"
      expect(event.owner).to eql '"owner" <owner@example.com>'
      expect(event.participants[0].comment).to eql "Let me think on it"
      expect(event.participants[0].phone_number).to eql "+14160000000"
      expect(event.participants[0].email).to eql "participant@example.com"
      expect(event.participants[0].name).to eql "Participant"
      expect(event.participants[0].status).to eql "noreply"
      expect(event.participants[1].comment).to be_nil
      expect(event.participants[1].email).to eql "owner@example.com"
      expect(event.participants[1].name).to eql "Owner"
      expect(event.participants[1].status).to eql "yes"
      expect(event).to be_read_only
      expect(event.status).to eql "confirmed"
      expect(event.title).to eql "An Event"
      expect(event.when.start_time).to eql Time.at(1_511_303_400)
      expect(event.when).to cover(Time.at(1_511_303_400))
      expect(event.when).not_to cover(Time.at(1_511_303_399))
      expect(event.when.end_time).to eql Time.at(1_511_306_400)
      expect(event.when).to cover(Time.at(1_511_306_400))
      expect(event.when).not_to cover(Time.at(1_511_306_401))
      expect(event.metadata[:event_type]).to eql "gathering"
      expect(event.conferencing.provider).to eql "Zoom Meeting"
      expect(event.conferencing.details.url).to eql "https://us02web.zoom.us/j/****************"
      expect(event.conferencing.details.meeting_code).to eql "213"
      expect(event.conferencing.details.password).to eql "xyz"
      expect(event.conferencing.details.phone).to eql ["+11234567890"]
      expect(event.notifications[0].type).to eql "email"
      expect(event.notifications[0].minutes_before_event).to be 60
      expect(event.notifications[0].subject).to eql "Test Event Notification"
      expect(event.notifications[0].body).to eql "Reminding you about our meeting."
    end
  end

  describe "busy?" do
    it "returns true when busy attribute from API return true" do
      api = instance_double(Nylas::API)
      data = {
        account_id: "acc-1234",
        busy: true,
        calendar_id: "cal-0987"
      }

      event = described_class.from_json(JSON.dump(data), api: api)

      expect(event).to be_busy
    end

    it "returns false when busy attribute from API return false" do
      api = instance_double(Nylas::API)
      data = {
        account_id: "acc-1234",
        busy: false,
        calendar_id: "cal-0987"
      }

      event = described_class.from_json(JSON.dump(data), api: api)

      expect(event).not_to be_busy
    end
  end

  describe "#read_only?" do
    it "returns true when read_only attribute from API return true" do
      api = instance_double(Nylas::API)
      data = {
        account_id: "acc-1234",
        read_only: true,
        calendar_id: "cal-0987"
      }

      event = described_class.from_json(JSON.dump(data), api: api)

      expect(event).to be_read_only
    end

    it "returns false when read_only attribute from API return false" do
      api = instance_double(Nylas::API)
      data = {
        account_id: "acc-1234",
        read_only: false,
        calendar_id: "cal-0987"
      }

      event = described_class.from_json(JSON.dump(data), api: api)

      expect(event).not_to be_read_only
    end
  end

  describe "#rsvp" do
    it "calls `Rsvp` with the given status and flag to notify_participants" do
      api = instance_double(Nylas::API)
      data = {
        id: "event-123",
        account_id: "acc-1234",
        read_only: false,
        calendar_id: "cal-0987"
      }
      rsvp = instance_double("Rsvp", save: nil)
      allow(Nylas::Rsvp).to receive(:new).and_return(rsvp)
      event = described_class.from_json(JSON.dump(data), api: api)

      event.rsvp(:yes, notify_participants: true)

      expect(Nylas::Rsvp).to have_received(:new).with(
        api: api,
        status: :yes,
        event_id: "event-123",
        notify_participants: true,
        account_id: "acc-1234"
      )
      expect(rsvp).to have_received(:save)
    end
  end

  describe "account_id" do
    context "when saving" do
      it "is excluded from payload" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-id",
          payload: {
            calendar_id: "cal-0987",
            read_only: false
          }.to_json,
          query: {}
        )
      end
    end
  end

  describe "object" do
    context "when saving" do
      it "is excluded from payload" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          object: "event",
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-id",
          payload: {
            calendar_id: "cal-0987"
          }.to_json,
          query: {}
        )
      end
    end
  end

  describe "id" do
    context "when saving" do
      it "is excluded from payload" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-id",
          payload: {
            calendar_id: "cal-0987"
          }.to_json,
          query: {}
        )
      end

      it "sends the conferencing autocreate object even if settings is empty" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          conferencing: {
            provider: "Zoom meetings",
            autocreate: {
              settings: {}
            }
          }
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-id",
          payload: {
            calendar_id: "cal-0987",
            conferencing: {
              provider: "Zoom meetings",
              autocreate: {
                settings: {}
              }
            }
          }.to_json,
          query: {}
        )
      end

      it "sends the conferencing object if details alone is set" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          conferencing: {
            provider: "Zoom meetings",
            details: {
              url: "https://us02web.zoom.us/j/****************",
              meeting_code: "213",
              password: "xyz",
              phone: [
                "+11234567890"
              ]
            }
          }
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-id",
          payload: {
            calendar_id: "cal-0987",
            conferencing: {
              provider: "Zoom meetings",
              details: {
                meeting_code: "213",
                password: "xyz",
                url: "https://us02web.zoom.us/j/****************",
                phone: [
                  "+11234567890"
                ]
              }
            }
          }.to_json,
          query: {}
        )
      end

      it "throws an error if both conferencing details and autocreate are set" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          conferencing: {
            provider: "Zoom meetings",
            details: {
              url: "https://us02web.zoom.us/j/****************",
              meeting_code: "213",
              password: "xyz",
              phone: [
                "+11234567890"
              ]
            },
            autocreate: {
              settings: {}
            }
          }
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        error = "Cannot set both 'details' and 'autocreate' in conferencing object."

        expect { event.save }.to raise_error(ArgumentError, error)
      end

      it "throws an error if capacity is less than the amount of participants" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          capacity: 1,
          participants: [{ email: "person1@email.com" }, { email: "person2@email.com" }]
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        error = "The number of participants in the event exceeds the set capacity."

        expect { event.save }.to raise_error(ArgumentError, error)
      end

      it "does not throw an error if capacity is -1" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          capacity: -1,
          participants: [{ email: "person1@email.com" }, { email: "person2@email.com" }]
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        expect { event.save }.not_to raise_error
      end

      it "does not throw an error if participants less than or equal to capacity" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          id: "event-id",
          calendar_id: "cal-0987",
          capacity: 2,
          participants: [{ email: "person1@email.com" }, { email: "person2@email.com" }]
        }
        event_capacity_equal = described_class.from_json(JSON.dump(data), api: api)
        data[:capacity] = 3
        event_capacity_greater = described_class.from_json(JSON.dump(data), api: api)

        expect { event_capacity_equal.save }.not_to raise_error
        expect { event_capacity_greater.save }.not_to raise_error
      end
    end
  end

  describe "reminder_minutes" do
    context "when saving" do
      it "is formatted properly if set to a numeric value" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          reminder_minutes: "20"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/events",
          payload: {
            reminder_minutes: "[20]"
          }.to_json,
          query: {}
        )
      end

      it "is left as-is if user already formatted properly" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          reminder_minutes: "[20]"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/events",
          payload: {
            reminder_minutes: "[20]"
          }.to_json,
          query: {}
        )
      end

      it "does not send reminder_minutes if unset" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          reminder_minutes: ""
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/events",
          payload: {}.to_json,
          query: {}
        )
      end
    end
  end

  describe "notify_participants" do
    context "when creating" do
      it "sends notify_participants in query params" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        event.notify_participants = true

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/events",
          payload: {
            calendar_id: "cal-0987",
            read_only: false
          }.to_json,
          query: {
            notify_participants: true
          }
        )
      end

      it "sends nothing when `notify_participants` is not set" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute).and_return({})
        data = {
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :post,
          path: "/events",
          payload: {
            calendar_id: "cal-0987",
            read_only: false
          }.to_json,
          query: {}
        )
      end
    end

    context "when updating" do
      it "sends notify_participants in query params" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute)
        data = {
          id: "event-8766",
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        event.notify_participants = true

        event.update(location: "Somewhere else!")

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-8766",
          payload: {
            location: "Somewhere else!"
          }.to_json,
          query: {
            notify_participants: true
          }
        )
      end

      it "sends nothing when `notify_participants` is not set" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute)
        data = {
          id: "event-8766",
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.update(location: "Somewhere else!")

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :put,
          path: "/events/event-8766",
          payload: {
            location: "Somewhere else!"
          }.to_json,
          query: {}
        )
      end
    end

    context "when deleting" do
      it "sends notify_participants in query params" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute)
        data = {
          id: "event-8766",
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        event.notify_participants = true

        event.destroy

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :delete,
          path: "/events/event-8766",
          payload: nil,
          query: {
            notify_participants: true
          }
        )
      end

      it "sends nothing when `notify_participants` is not set" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute)
        data = {
          id: "event-8766",
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.destroy

        expect(api).to have_received(:execute).with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :delete,
          path: "/events/event-8766",
          payload: nil,
          query: {}
        )
      end
    end
  end

  describe "generating an ICS" do
    it "sends the event ID if set" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute).and_return({})
      data = {
        id: "event-id",
        calendar_id: "cal-0987",
        title: "An Event",
        when: {
          end_time: 1_511_306_400,
          start_time: 1_511_303_400
        }
      }
      event = described_class.from_json(JSON.dump(data), api: api)

      event.generate_ics

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/events/to-ics",
        payload: {
          event_id: "event-id"
        }.to_json
      )
    end

    it "sends the event object if event id is not set" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute).and_return({})
      data = {
        calendar_id: "cal-0987",
        title: "An Event",
        when: {
          end_time: 1_511_306_400,
          start_time: 1_511_303_400
        }
      }
      event = described_class.from_json(JSON.dump(data), api: api)

      event.generate_ics

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/events/to-ics",
        payload: {
          calendar_id: "cal-0987",
          title: "An Event",
          when: {
            start_time: 1_511_303_400,
            end_time: 1_511_306_400
          }
        }.to_json
      )
    end

    it "throws an error if event has no calendar ID set" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute).and_return({})
      data = {
        title: "An Event",
        when: {
          end_time: 1_511_306_400,
          start_time: 1_511_303_400
        }
      }
      event = described_class.from_json(JSON.dump(data), api: api)
      error = "Cannot generate an ICS file for an event without a Calendar ID or when set"

      expect { event.generate_ics }.to raise_error(ArgumentError, error)
    end

    it "throws an error if event has no when object set" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute).and_return({})
      data = {
        calendar_id: "cal-0987",
        title: "An Event"
      }
      event = described_class.from_json(JSON.dump(data), api: api)
      error = "Cannot generate an ICS file for an event without a Calendar ID or when set"

      expect { event.generate_ics }.to raise_error(ArgumentError, error)
    end
  end
end
