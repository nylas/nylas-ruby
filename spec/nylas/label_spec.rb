describe Nylas::Label do
  it "is not searchable" do
    expect(described_class).not_to be_searchable
  end

  it "is collectionable" do
    expect(described_class).to be_collectionable
  end

  it "is not read only" do
    expect(described_class).not_to be_read_only
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
