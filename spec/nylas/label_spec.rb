# frozen_string_literal: true

describe Nylas::Label do
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  it "is creatable" do
    expect(described_class).to be_creatable
  end

  it "is updatable" do
    expect(described_class).to be_updatable
  end

  describe ".from_json" do
    it "deserializes all the attributes successfully" do
      data = {
        id: "label-all-mail",
        account_id: "acc-234",
        display_name: "All Mail",
        name: "all",
        provider_id: "provider-id"
      }

      label = described_class.from_json(JSON.dump(data), api: nil)
      expect(label.display_name).to eql "All Mail"
      expect(label.id).to eql "label-all-mail"
      expect(label.name).to eql "all"
      expect(label.account_id).to eql "acc-234"
      expect(label.provider_id).to eql "provider-id"
    end
  end
end
