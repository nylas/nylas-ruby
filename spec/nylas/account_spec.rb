# frozen_string_literal: true

describe Nylas::Account do
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  it "can be deserialized from JSON" do
    json = JSON.dump(
      account_id: "30zipv27dtrsnkleg59mprw5p",
      billing_state: "paid",
      email: "test@example.com",
      id: "30zipv27dtrsnkleg59mprw5p",
      sync_state: "running",
      authentication_type: "password",
      trial: false,
      provider: "gmail",
      metadata: {
        key: "value"
      }
    )
    account = described_class.from_json(json, api: nil)
    expect(account.account_id).to eql "30zipv27dtrsnkleg59mprw5p"
    expect(account.billing_state).to eql "paid"
    expect(account.email).to eql "test@example.com"
    expect(account.id).to eql "30zipv27dtrsnkleg59mprw5p"
    expect(account.sync_state).to eql "running"
    expect(account.authentication_type).to eql "password"
    expect(account.trial).to be false
    expect(account.provider).to eq("gmail")
    expect(account.metadata).to include(key: "value")
  end

  it "can update metadata" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    account.metadata = {
      key: "value"
    }
    account.save

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :put,
      path: "/a/app-987/accounts/acc-1234",
      payload: JSON.dump(
        metadata: {
          key: "value"
        }
      ),
      query: {}
    )
  end

  it "can be downgraded" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    expect(account.downgrade).to be_truthy

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :post,
      path: "/a/app-987/accounts/acc-1234/downgrade",
      payload: nil,
      query: {}
    )
  end

  it "can be upgraded" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    expect(account.upgrade).to be_truthy

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :post,
      path: "/a/app-987/accounts/acc-1234/upgrade",
      payload: nil,
      query: {}
    )
  end

  it "can revoke all tokens" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)
    access_token = "some_access_token"

    expect(account.revoke_all(keep_access_token: access_token)).to be_truthy

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :post,
      path: "/a/app-987/accounts/acc-1234/revoke-all",
      payload: be_json("keep_access_token" => access_token),
      query: {}
    )
  end

  it "can be destroyed" do
    api = instance_double("Nylas::API", execute: { success: true }, app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)

    expect(account.destroy).to be_truthy

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :delete,
      path: "/a/app-987/accounts/acc-1234",
      payload: nil,
      query: {}
    )
  end

  it "can return token information" do
    api = instance_double("Nylas::API", app_id: "app-987")
    account = described_class.from_json('{ "id": "acc-1234" }', api: api)
    token_info_response = {
      scopes: "email.send,email.modify,calendar",
      state: "valid",
      created_at: 1622492343,
      updated_at: 1622492343
    }
    allow(api).to receive(:execute).and_return(token_info_response)

    token_info = account.token_info("test-token")

    expect(api).to have_received(:execute).with(
      auth_method: Nylas::HttpClient::AuthMethod::BASIC,
      method: :post,
      path: "/a/app-987/accounts/acc-1234/token-info",
      payload: be_json("access_token" => "test-token"),
      query: {}
    )
    expect(token_info.scopes).to be("email.send,email.modify,calendar")
    expect(token_info.state).to be("valid")
    expect(token_info.created_at).to eql(Time.at(1622492343))
    expect(token_info.updated_at).to eql(Time.at(1622492343))
    expect(token_info.valid?).to be(true)
  end
end
