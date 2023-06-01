# frozen_string_literal: true

require_relative "resources/calendars"
require_relative "resources/events"
require_relative "resources/auth"
require_relative "resources/webhooks"
require_relative "resources/application"

module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects
  class Client
    attr_reader :api_key, :host, :client_id, :client_secret, :timeout

    def initialize(api_key: nil,
                   client_id: nil,
                   client_secret: nil,
                   host: DEFAULT_REGION_URL,
                   timeout: nil)
      @api_key = api_key
      @client_id = client_id
      @client_secret = client_secret
      @host = "#{host}/v3"
      @timeout = timeout
    end

    # The application resources for your Nylas application
    # @return [Nylas::Application] The application resources for your Nylas application
    def application
      Application.new(self)
    end

    # The calendar resources for your Nylas application
    # @return [Nylas::Calendars] The calendar resources for your Nylas application
    def calendars
      Calendars.new(self)
    end

    # The event resources for your Nylas application
    # @return [Nylas::Events] The event resources for your Nylas application
    def events
      Events.new(self)
    end

    # The auth resources for your Nylas application
    # @return [Nylas::Auth] The auth resources for your Nylas application
    def auth
      Auth.new(self)
    end

    # The webhook resources for your Nylas application
    # @return [Nylas::Webhooks] The webhook resources for your Nylas application
    def webhooks
      Webhooks.new(self)
    end
  end
end
