require "spec_helper"

describe Nylas::CurrentAccount do
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end
  it "is not listable" do
    expect(described_class).not_to be_listable
  end

  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  it "is not updatable" do
    expect(described_class).not_to be_updatable
  end

  it "is showable" do
    expect(described_class).to be_showable
  end

  it "can be deserialized from JSON" do
    api = FakeAPI.new
    json = '{ "id": "awa6ltos76vz5hvphkp8k17nt", "account_id": "awa6ltos76vz5hvphkp8k17nt", ' \
           '  "object": "account", "name": "Example Name", "email_address": "example@example.com", ' \
           '  "provider": "gmail", "organization_unit": "label", "sync_state": "running" }'

    account = described_class.from_json(json, api: api)

    expect(account.email_address).to eql "example@example.com"
    expect(account.name).to eql "Example Name"
    expect(account.provider).to eql "gmail"
    expect(account.organization_unit).to eql "label"
    expect(account.sync_state).to eql "running"
  end

  it "can be serialized back into JSON" do
    api = FakeAPI.new
    json = '{ "id": "awa6ltos76vz5hvphkp8k17nt", "account_id": "awa6ltos76vz5hvphkp8k17nt", ' \
           '  "object": "account", "name": "Example Name", "email_address": "example@example.com", ' \
           '  "provider": "gmail", "organization_unit": "label", "sync_state": "running" }'

    account = described_class.from_json(json, api: api)

    expect(JSON.parse(account.to_json)).to eql(JSON.parse(json))
  end
end
