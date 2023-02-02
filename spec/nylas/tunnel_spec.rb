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

class MockMessage
  attr_accessor :data
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

def on_message(delta)
  delta
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

  describe "open_webhook_tunnel" do
    before do
      allow(EM).to receive(:run).and_yield
      allow(SecureRandom).to receive(:uuid).and_return("tunnel-123")
      allow(described_class).to receive(:setup_websocket_client)
      allow(described_class).to receive(:register_webhook_callback)
    end

    it "calls the functions with the default values" do
      default_webhooks = %w[contact.created contact.updated contact.deleted calendar.created calendar.updated
                            calendar.deleted event.created event.updated event.deleted job.successful
                            job.failed account.connected account.running account.stopped account.invalid
                            account.sync_error message.created message.opened message.link_created
                            message.updated message.bounced thread.replied]

      described_class.open_webhook_tunnel(api)

      expect(described_class).to have_received(:setup_websocket_client)
        .with("tunnel.nylas.com", api, "tunnel-123", "us", {})
      expect(described_class).to have_received(:register_webhook_callback)
        .with(api, "cb.nylas.com", "tunnel-123", default_webhooks)
    end

    it "calls the functions with the correct values" do
      config = {
        region: "ireland",
        triggers: [WebhookTrigger::ACCOUNT_CONNECTED]
      }

      described_class.open_webhook_tunnel(api, config)

      expect(described_class).to have_received(:setup_websocket_client)
        .with("tunnel.nylas.com", api, "tunnel-123", "ireland", config)
      expect(described_class).to have_received(:register_webhook_callback)
        .with(api, "cb.nylas.com", "tunnel-123", ["account.connected"])
    end
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
          on_error: method(:on_error),
          on_message: method(:on_message)
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

    it "handles delta parsing on message properly" do
      message = MockMessage.new
      delta_callback = ws.listeners["message"].call(message)
      expect(delta_callback).to be(nil)

      # rubocop:disable Layout/LineLength
      message.data = '{"body": "{\\"deltas\\": [{\\"date\\": 1675098465, \\"object\\": \\"message\\", \\"type\\": \\"message.created\\", \\"object_data\\": {\\"namespace_id\\": \\"namespace_123\\", \\"account_id\\": \\"account_123\\", \\"object\\": \\"message\\", \\"attributes\\": {\\"thread_id\\": \\"thread_123\\", \\"received_date\\": 1675098459}, \\"id\\": \\"123\\", \\"metadata\\": null}}]}"}'
      # rubocop:enable Layout/LineLength

      delta_callback = ws.listeners["message"].call(message)
      expect(delta_callback).not_to be(nil)
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

  describe "parse_deltas_from_message" do
    let(:message) { MockMessage.new }

    it "parses the delta when the message is set" do
      # rubocop:disable Layout/LineLength
      message.data = '{"body": "{\\"deltas\\": [{\\"date\\": 1675098465, \\"object\\": \\"message\\", \\"type\\": \\"message.created\\", \\"object_data\\": {\\"namespace_id\\": \\"namespace_123\\", \\"account_id\\": \\"account_123\\", \\"object\\": \\"message\\", \\"attributes\\": {\\"thread_id\\": \\"thread_123\\", \\"received_date\\": 1675098459}, \\"id\\": \\"123\\", \\"metadata\\": null}}]}"}'
      # rubocop:enable Layout/LineLength
      json = {
        "date" => 1675098465,
        "object" => "message",
        "type" => "message.created",
        "object_data" => {
          "namespace_id" => "namespace_123",
          "account_id" => "account_123",
          "object" => "message",
          "id" => "123",
          "metadata" => nil,
          "attributes" => {
            "thread_id" => "thread_123",
            "received_date" => 1675098459
          }
        }
      }

      result = described_class.send(:parse_deltas_from_message, message)

      expect(result).to be_a(Array)
      expect(result.length).to be(1)
      expect(result[0]).to eql(json)
    end

    it "returns if message data is empty" do
      result = described_class.send(:parse_deltas_from_message, message)

      expect(result).to be(nil)
    end
  end

  describe "merge_and_create_delta" do
    it "serializes it into the Delta object" do
      delta = {
        "date" => 1675098465,
        "object" => "message",
        "type" => "message.created",
        "object_data" => {
          "namespace_id" => "namespace_123",
          "account_id" => "account_123",
          "object" => "message",
          "id" => "123",
          "metadata" => nil,
          "attributes" => {
            "thread_id" => "thread_123",
            "received_date" => 1675098459
          }
        }
      }

      serialized = described_class.send(:merge_and_create_delta, delta)

      expect(serialized).to be_a(Nylas::Delta)
      expect(serialized.date).to eql(Time.at(1675098465))
      expect(serialized.object).to eql("message")
      expect(serialized.type).to eql("message.created")
      expect(serialized.namespace_id).to eql("namespace_123")
      expect(serialized.account_id).to eql("account_123")
      expect(serialized.object).to eql("message")
      expect(serialized.id).to eql("123")
      attributes = serialized.object_attributes
      expect(attributes["thread_id"]).to eql("thread_123")
      expect(attributes["received_date"]).to be(1675098459)
    end
  end
end
