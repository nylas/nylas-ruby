# frozen_string_literal: true

require "securerandom"
require "faye/websocket"
require "eventmachine"

module Nylas
  # Class containing methods to spin up a developmental websocket connection to test webhooks
  class Tunnel
    # Open a webhook tunnel and register it with the Nylas API
    # 1. Creates a UUID
    # 2. Opens a websocket connection to Nylas' webhook forwarding service, with the UUID as a header
    # 3. Creates a new webhook pointed at the forwarding service with the UUID as the path
    # When an event is received by the forwarding service, it will push directly to this websocket connection
    #
    # @param api [Nylas::API] The configured Nylas API client
    # @param config [Hash] Configuration for the webhook tunnel, including callback functions, region, and
    #   events to subscribe to
    def self.open_webhook_tunnel(api, config = nil)
      tunnel_id = SecureRandom.uuid
      triggers = config[:triggers]
      region = config[:region]
      websocket_domain = "tunnel.nylas.com"
      callback_domain = "cb.nylas.com"

      EM.run do
        setup_websocket_client(websocket_domain, api, tunnel_id, region, config)
        register_webhook_callback(api, callback_domain, tunnel_id, triggers)
      end
    end

    # Register callback with the Nylas forwarding service which will pass messages to the websocket
    # @param api [Nylas::API] The configured Nylas API client
    # @param callback_domain [String] The domain name of the callback
    # @param tunnel_path [String] The path to the tunnel
    # @param triggers [Array<WebhookTrigger>] The list of triggers to subscribe to
    # @return [Nylas::Webhook] The webhook details response from the API
    def self.register_webhook_callback(api, callback_domain, tunnel_path, triggers)
      callback_url = "https://#{callback_domain}/#{tunnel_path}"

      api.webhooks.create(
        callback_url: callback_url,
        state: WebhookState::ACTIVE,
        triggers: triggers
      )
    end

    # Setup the websocket client and register the callbacks
    # @param websocket_domain [String] The domain of the websocket to connect to
    # @param api [Nylas::API] The configured Nylas API client
    # @param tunnel_id [String] The ID of the tunnel
    # @param region [String] The Nylas region to configure for
    # @param config [Hash] The object containing all the callback methods
    def self.setup_websocket_client(websocket_domain, api, tunnel_id, region, config)
      ws = Faye::WebSocket::Client.new(
        "wss://#{websocket_domain}",
        [],
        {
          headers: {
            "Client-Id" => api.client.app_id,
            "Client-Secret" => api.client.app_secret,
            "Tunnel-Id" => tunnel_id,
            "Region" => region
          }
        }
      )

      ws.on :open do |event|
        config[:on_open].call(event) if callable(config[:on_open])
      end

      ws.on :close do |close|
        config[:on_close].call(close) if callable(config[:on_close])
        EM.stop
      end

      ws.on :error do |error|
        config[:on_error].call(error) if callable(config[:on_error])
      end

      ws.on :message do |message|
        json = JSON.parse(message.data)
        deltas = JSON.parse(json["body"])["deltas"]
        next if deltas.nil?

        deltas.each do |delta|
          object_data = delta.delete("object_data")
          delta = delta.merge(object_data).transform_keys(&:to_sym)
          config[:on_message].call(Delta.new(**delta)) if callable(config[:on_message])
        end
      end
    end

    # Check if the object is a method
    # @param obj [Any] The object to check
    # @return [Boolean] True if the object is a method
    def self.callable(obj)
      !obj.nil? && obj.respond_to?(:call)
    end

    private_class_method :build_webhook_tunnel, :setup_websocket_client, :callable
  end
end
