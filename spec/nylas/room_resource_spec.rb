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

      label = described_class.from_json(json, api: nil)

      expect(label.object).to eql "room_resource"
      expect(label.email).to eql "training-room@outlook.com"
      expect(label.name).to eql "Microsoft Training Room"
      expect(label.building).to eql "Seattle"
      expect(label.capacity).to eql "5"
      expect(label.floor_name).to eql "Office"
      expect(label.floor_number).to eql "2"
    end
  end
end
