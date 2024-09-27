# frozen_string_literal: true

require "spec_helper"

describe Nylas::Webhook do
  it "is creatable" do
    expect(described_class).to be_creatable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  it "is showable" do
    expect(described_class).to be_showable
  end

  it "is updatable" do
    expect(described_class).to be_updatable
  end

  it "is destroyable" do
    expect(described_class).to be_destroyable
  end

  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API)
      data = {
        id: "webhook-123",
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      expect(webhook.id).to eql "webhook-123"
      expect(webhook.application_id).to eql "app-123"
      expect(webhook.callback_url).to eql "https://url.com/callback"
      expect(webhook.state).to eql "active"
      expect(webhook.triggers).to eql ["event.created"]
      expect(webhook.version).to eql "v1"
    end
  end

  describe "#create" do
    it "Serializes all non-read-only attributes" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      webhook.create

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :post,
        path: "/a/app-987/webhooks",
        payload: JSON.dump(
          callback_url: "https://url.com/callback",
          state: "active",
          triggers: ["event.created"]
        ),
        query: {}
      )
    end
  end

  describe "update" do
    it "Serializes only state" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        id: "webhook-123",
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      webhook.update(state: Nylas::V2::WebhookState::INACTIVE)

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :put,
        path: "/a/app-987/webhooks/webhook-123",
        payload: JSON.dump(
          state: "inactive"
        ),
        query: {}
      )
    end

    it "Throws an error if update was called with something other than just state" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        id: "webhook-123",
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      expect do
        webhook.update(version: "v2")
      end.to raise_error(ArgumentError, "Only 'state' is allowed to be updated")
    end
  end

  describe "save" do
    it "Creates if no id exists" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      webhook.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :post,
        path: "/a/app-987/webhooks",
        payload: JSON.dump(
          callback_url: "https://url.com/callback",
          state: "active",
          triggers: ["event.created"]
        ),
        query: {}
      )
    end

    it "Updates if id exists" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        id: "webhook-123",
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      webhook.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :put,
        path: "/a/app-987/webhooks/webhook-123",
        payload: JSON.dump(
          state: "active"
        ),
        query: {}
      )
    end
  end

  describe "#destroy" do
    it "Deletes the webhook on the API" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"), app_id: "app-987")
      data = {
        id: "webhook-123",
        application_id: "app-123",
        callback_url: "https://url.com/callback",
        state: "active",
        triggers: [Nylas::V2::WebhookTrigger::EVENT_CREATED],
        version: "v1"
      }

      webhook = described_class.from_json(JSON.dump(data), api: api)

      webhook.destroy

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :delete,
        path: "/a/app-987/webhooks/webhook-123",
        payload: nil,
        query: {}
      )
    end
  end

  describe "verify_webhook_signature" do
    it "returns true if the webhook signature is valid" do
      is_verified = described_class.verify_webhook_signature(
        "ddc02f921a4835e310f249dc09770c3fea2cb6fe949adc1887d7adc04a581e1c",
        "test123",
        "myClientSecret"
      )

      expect(is_verified).to be(true)
    end

    it "returns false if the webhook signature is invalid" do
      is_verified = described_class.verify_webhook_signature(
        "ddc02f921a4835e310f249dc09770c3fea2cb6fe949adc1887d7adc04a581e1c",
        "test1234",
        "myClientSecret"
      )

      expect(is_verified).to be(false)
    end
  end
end
