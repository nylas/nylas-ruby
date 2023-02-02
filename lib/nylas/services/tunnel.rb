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
    def self.open_webhook_tunnel(api, config = {})
      tunnel_id = SecureRandom.uuid
      triggers = config[:triggers] || WebhookTrigger.constants(false).map { |c| WebhookTrigger.const_get c }
      region = config[:region] || "us"
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
    # @return [WebSocket::Client] The configured websocket client
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
        deltas = parse_deltas_from_message(message)
        next if deltas.nil?

        deltas.each do |delta|
          delta = merge_and_create_delta(delta)
          config[:on_message].call(delta) if callable(config[:on_message])
        end
      end

      ws
    end

    # Check if the object is a method
    # @param obj [Any] The object to check
    # @return [Boolean] True if the object is a method
    def self.callable(obj)
      !obj.nil? && obj.respond_to?(:call)
    end

    # Parse deltas from the message object
    # @param message [Any] The message object containing the deltas
    # @return [Hash] The parsed list of deltas
    def self.parse_deltas_from_message(message)
      return unless message.data

      json = JSON.parse(message.data)
      JSON.parse(json["body"])["deltas"]
    end

    # Clean up and create the delta object
    # @param delta [Hash] The hash containing the delta attributes from the API
    # @return [Nylas::Delta] The delta object
    def self.merge_and_create_delta(delta)
      object_data = delta.delete("object_data")
      attributes = object_data.delete("attributes")
      object_data["object_attributes"] = attributes
      delta = delta.merge(object_data).transform_keys(&:to_sym)
      Delta.new(**delta)
    end

    private_class_method :setup_websocket_client,
                         :callable,
                         :parse_deltas_from_message,
                         :merge_and_create_delta
  end
end
