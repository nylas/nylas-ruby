# frozen_string_literal: true

require "spec_helper"

describe Nylas::CurrentAccount do
  # Restrict the ability to filter the current account.
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  # Restrict the ability to list the current account.
  it "is not listable" do
    expect(described_class).not_to be_listable
  end

  # Restrict the ability to create the current account.
  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  # Restrict the ability to update the current account.
  it "is not updatable" do
    expect(described_class).not_to be_updatable
  end

  # Allow the current account to be displayed.
  it "is showable" do
    expect(described_class).to be_showable
  end

  # Allow the current account's parameters to be deserialized from JSON.
  it "can be deserialized from JSON" do
    api = FakeAPI.new
    json = '{ "id": "awa6ltos76vz5hvphkp8k17nt", "account_id": "awa6ltos76vz5hvphkp8k17nt", ' \
           '  "object": "account", "name": "Example Name", "linked_at": 1517870623, ' \
           '  "email_address": "example@example.com", ' \
           '  "provider": "gmail", "organization_unit": "label", "sync_state": "running" }'

    account = described_class.from_json(json, api: api)

    expect(account.email_address).to eql "example@example.com"
    expect(account.name).to eql "Example Name"
    expect(account.provider).to eql "gmail"
    expect(account.organization_unit).to eql "label"
    expect(account.sync_state).to eql "running"
  end

  # Allow the current account's parameters to be serialized to JSON.
  it "can be serialized back into JSON" do
    api = FakeAPI.new
    json = '{ "id": "awa6ltos76vz5hvphkp8k17nt", "account_id": "awa6ltos76vz5hvphkp8k17nt", ' \
           '  "object": "account", "name": "Example Name", "linked_at": 1517870623, ' \
           '  "email_address": "example@example.com", ' \
           '  "provider": "gmail", "organization_unit": "label", "sync_state": "running" }'

    account = described_class.from_json(json, api: api)

    expect(JSON.parse(account.to_json)).to eql(JSON.parse(json))
  end
end
