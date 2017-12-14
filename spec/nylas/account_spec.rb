describe Nylas::Account do
  it "is not searchable" do
    expect(described_class).not_to be_searchable
  end

  it "is read only" do
    expect(described_class).to be_read_only
  end

  it "is collectionable" do
    expect(described_class).to be_collectionable
  end

  it "can be deserialized from JSON" do
    json = JSON.dump(account_id: "30zipv27dtrsnkleg59mprw5p", billing_state: "paid",
                     email: "test@example.com", id: "30zipv27dtrsnkleg59mprw5p", sync_state: "running",
                     trial: false)
    account = described_class.from_json(json, api: nil)
    expect(account.account_id).to eql "30zipv27dtrsnkleg59mprw5p"
    expect(account.billing_state).to eql "paid"
    expect(account.email).to eql "test@example.com"
    expect(account.id).to eql "30zipv27dtrsnkleg59mprw5p"
    expect(account.sync_state).to eql "running"
    expect(account.trial).to be false
  end

  it "can be downgraded" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    expect(account.downgrade).to be_truthy

    expect(api).to have_received(:execute).with(method: :post, path: "/a/app-987/accounts/acc-1234/downgrade",
                                                payload: nil)
  end
  it "can be upgraded" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    expect(account.upgrade).to be_truthy

    expect(api).to have_received(:execute).with(method: :post, path: "/a/app-987/accounts/acc-1234/upgrade",
                                                payload: nil)
  end
end
