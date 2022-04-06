# frozen_string_literal: true

describe Nylas::RoomResource do
  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  it "is not be_updatable" do
    expect(described_class).not_to be_updatable
  end

  it "is not destroyable" do
    expect(described_class).not_to be_destroyable
  end

  it "is not showable" do
    expect(described_class).not_to be_showable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  describe "#from_json" do
    it "deserializes all the attributes successfully" do
      json = JSON.dump("object": "room_resource",
                       "email": "training-room@outlook.com",
                       "name": "Microsoft Training Room",
                       "building": "Seattle",
                       "capacity": "5",
                       "floor_name": "Office",
                       "floor_number": "2")

      resource = described_class.from_json(json, api: nil)

      expect(resource.object).to eql "room_resource"
      expect(resource.email).to eql "training-room@outlook.com"
      expect(resource.name).to eql "Microsoft Training Room"
      expect(resource.building).to eql "Seattle"
      expect(resource.capacity).to eql "5"
      expect(resource.floor_name).to eql "Office"
      expect(resource.floor_number).to eql "2"
    end
  end

  context "when getting" do
    it "makes a call to the /resources endpoint" do
      api = instance_double(Nylas::API, execute: "{}")
      resource = Nylas::Collection.new(model: described_class, api: api)

      api.execute(resource.to_be_executed)

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/resources",
        headers: {},
        query: { limit: 100, offset: 0 }
      )
    end
  end
end
