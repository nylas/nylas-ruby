# frozen_string_literal: true

require "rspec"

##
# Mock class and functions
##

class MockWebsocketClient
  attr_accessor :url, :protocols, :options, :listeners

  def initialize(url, protocols, options)
    self.url = url
    self.protocols = protocols
    self.options = options
    self.listeners = {}
  end

  def on(event, &block)
    listeners[event.to_s] = block
  end
end

def on_open(_)
  "on_open"
end

def on_close(_)
  "on_close"
end

def on_error(_)
  "on_error"
end

describe Nylas::Tunnel do
  let(:client) do
    Nylas::HttpClient.new(
      app_id: "not-real",
      app_secret: "also-not-real"
    )
  end
  let(:api) do
    instance_double(
      Nylas::API,
      client: client,
      webhooks: Nylas::Collection.new(model: Nylas::Webhook, api: client)
    )
  end

  describe "register_webhook_callback" do
    it "creates a webhook with the correct parameters" do
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

  describe "setup_websocket_client" do
    let(:ws) do
      described_class.send(
        :setup_websocket_client,
        "tunnel.nylas.com",
        api,
        "tunnel-123",
        "us",
        {
          region: "us",
          triggers: ["event.updated"],
          on_open: method(:on_open),
          on_close: method(:on_close),
          on_error: method(:on_error)
        }
      )
    end

    before do
      stub_const("Faye::WebSocket::Client", MockWebsocketClient)
    end

    it "passes the correct values to the websockets init" do
      options = {
        headers: {
          "Client-Id" => "not-real",
          "Client-Secret" => "also-not-real",
          "Tunnel-Id" => "tunnel-123",
          "Region" => "us"
        }
      }

      expect(ws.url).to eql("wss://tunnel.nylas.com")
      expect(ws.protocols).to eql([])
      expect(ws.options).to eql(options)
    end

    it "set the correct callbacks and is callable" do
      allow(EM).to receive(:stop)

      expect(ws.listeners["open"].call).to eql("on_open")
      expect(ws.listeners["close"].call).to be(nil)
      expect(EM).to have_received(:stop)
      expect(ws.listeners["error"].call).to eql("on_error")
    end
  end

  describe "callable" do
    it "correctly identifies a callable objects vs. un-callable ones" do
      string = "random string"

      callable = described_class.send(:callable, method(:on_open))
      uncallable = described_class.send(:callable, string)

      expect(callable).to be(true)
      expect(uncallable).to be(false)
    end
  end
end
