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
        }
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

  describe "notify_participants" do
    context "when saving" do
      it "sends notify_participants in query params" do
        api = instance_double(Nylas::API)
        allow(api).to receive(:execute)
        data = {
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)
        event.notify_participants = true

        event.save

        expect(api).to have_received(:execute).with(
          method: :post,
          path: "/events",
          payload: {
            account_id: "acc-1234",
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
        allow(api).to receive(:execute)
        data = {
          account_id: "acc-1234",
          read_only: false,
          calendar_id: "cal-0987"
        }
        event = described_class.from_json(JSON.dump(data), api: api)

        event.save

        expect(api).to have_received(:execute).with(
          method: :post,
          path: "/events",
          payload: {
            account_id: "acc-1234",
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
          method: :delete,
          path: "/events/event-8766",
          payload: nil,
          query: {}
        )
      end
    end
  end
end
