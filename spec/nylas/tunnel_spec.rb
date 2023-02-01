# frozen_string_literal: true

require "rspec"

describe Nylas::Tunnel do
  describe "register_webhook_callback" do
    it "creates a webhook with the correct parameters" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real"
      )
      api = instance_double(
        Nylas::API,
        client: client,
        webhooks: Nylas::Collection.new(model: Nylas::Webhook, api: client)
      )
      allow(client).to receive(:execute).and_return({})
      callback_domain = "domain.com"
      tunnel_path = "tunnel"
      triggers = [WebhookTrigger::EVENT_CREATED]

      described_class.register_webhook_callback(api, callback_domain, tunnel_path, triggers)

      expect(client).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BASIC,
        method: :post,
        path: "/a/not-real/webhooks",
        payload: JSON.dump(
          callback_url: "https://domain.com/tunnel",
          state: "active",
          triggers: ["event.created"]
        ),
        query: {}
      )
    end
  end
end
