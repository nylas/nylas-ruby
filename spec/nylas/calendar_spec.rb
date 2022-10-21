# frozen_string_literal: true

describe Nylas::Calendar do
  describe "JSONs" do
    let(:calendar) do
      api = instance_double(Nylas::API)
      data = {
        id: "cal-8766",
        object: "calendar",
        account_id: "acc-1234",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        location: "Ruby SDK",
        timezone: "America/New_York",
        job_status_id: "job-1234",
        metadata: {
          lang: "ruby"
        },
        hex_color: "#0099EE",
        is_primary: false,
        read_only: true
      }

      described_class.from_json(JSON.dump(data), api: api)
    end

    it "Deserializes all the attributes into Ruby objects" do
      expect(calendar.id).to eql "cal-8766"
      expect(calendar.object).to eql "calendar"
      expect(calendar.account_id).to eql "acc-1234"
      expect(calendar.name).to eql "My Calendar"
      expect(calendar.description).to eql "Ruby Test Calendar"
      expect(calendar.location).to eql "Ruby SDK"
      expect(calendar.timezone).to eql "America/New_York"
      expect(calendar.job_status_id).to eql "job-1234"
      expect(calendar.metadata).to eq(lang: "ruby")
      expect(calendar.hex_color).to eql "#0099EE"
      expect(calendar.is_primary).to be false
      expect(calendar.read_only).to be true
    end

    it "Serializes all non-read only attributes for the API" do
      expected_json = {
        id: "cal-8766",
        account_id: "acc-1234",
        object: "calendar",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        is_primary: false,
        location: "Ruby SDK",
        timezone: "America/New_York",
        read_only: true,
        metadata: {
          lang: "ruby"
        }
      }.to_json

      json = calendar.attributes.serialize_for_api

      expect(json).to eql expected_json
    end
  end

  describe "read on" do
    it "Serializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API)
      data = {
        id: "cal-8766",
        object: "calendar",
        account_id: "acc-1234",
        name: "My Calendar",
        description: "Ruby Test Calendar",
        location: "Ruby SDK",
        timezone: "America/New_York",
        job_status_id: "job-1234",
        metadata: {
          lang: "ruby"
        },
        hex_color: "#0099EE",
        is_primary: false,
        read_only: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar.id).to eql "cal-8766"
      expect(calendar.object).to eql "calendar"
      expect(calendar.account_id).to eql "acc-1234"
      expect(calendar.name).to eql "My Calendar"
      expect(calendar.description).to eql "Ruby Test Calendar"
      expect(calendar.location).to eql "Ruby SDK"
      expect(calendar.timezone).to eql "America/New_York"
      expect(calendar.job_status_id).to eql "job-1234"
      expect(calendar.metadata).to eq(lang: "ruby")
      expect(calendar.hex_color).to eql "#0099EE"
      expect(calendar.is_primary).to be false
      expect(calendar.read_only).to be true
    end
  end

  describe "#read_only?" do
    it "returns true when read_only attribute from API return true" do
      api = instance_double(Nylas::API)
      data = {
        read_only: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).to be_read_only
    end

    it "returns false when read_only attribute from API return false" do
      api = instance_double(Nylas::API)
      data = {
        read_only: false
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).not_to be_read_only
    end
  end

  describe "#primary?" do
    it "returns true when is_primary attribute from API return true" do
      api = instance_double(Nylas::API)
      data = {
        is_primary: true
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).to be_primary
    end

    it "returns false when is_primary attribute from API return false" do
      api = instance_double(Nylas::API)
      data = {
        is_primary: false
      }

      calendar = described_class.from_json(JSON.dump(data), api: api)

      expect(calendar).not_to be_primary
    end
  end

  describe "#events" do
    it "sets the constraints properly for getting child events" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      events = Nylas::EventCollection.new(model: Nylas::Event, api: api)
      allow(api).to receive(:events).and_return(events)
      data = {
        id: "cal-123"
      }
      calendar = described_class.from_json(JSON.dump(data), api: api)

      event_collection = calendar.events

      expect(event_collection).to be_a Nylas::EventCollection

      event_collection.execute

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        headers: {},
        method: :get,
        path: "/events",
        query: { calendar_id: "cal-123", limit: 100, offset: 0 }
      )
    end
  end
end
