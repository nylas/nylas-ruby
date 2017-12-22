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

  describe "#from_json" do
    it "deserializes all the attributes successfully" do
      json = JSON.dump(display_name: "All Mail", id: "label-all-mail", name: "all", account_id: "acc-234")
      label = described_class.from_json(json, api: nil)
      expect(label.display_name).to eql "All Mail"
      expect(label.id).to eql "label-all-mail"
      expect(label.name).to eql "all"
      expect(label.account_id).to eql "acc-234"
    end
  end
end
