# frozen_string_literal: true

require_relative "resources/calendars"
require_relative "resources/events"
require_relative "resources/auth"
require_relative "resources/webhooks"
require_relative "resources/applications"

module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects.
  class Client
    attr_reader :api_key, :api_uri, :timeout

    # Initializes a client session.
    #
    # @param api_key [Hash, nil] API key to use for the client session.
    # @param api_uri [Hash] Client session's host.
    # @param timeout [Hash, nil] Timeout value to use for the client session.
    def initialize(api_key: nil,
                   api_uri: Config::DEFAULT_REGION_URL,
                   timeout: nil)
      @api_key = api_key
      @api_uri = api_uri
      @timeout = timeout
    end

    # The application resources for your Nylas application.
    #
    # @return [Nylas::Applications] Application resources for your Nylas application.
    def applications
      Applications.new(self)
    end

    # The calendar resources for your Nylas application.
    #
    # @return [Nylas::Calendars] Calendar resources for your Nylas application.
    def calendars
      Calendars.new(self)
    end

    # The event resources for your Nylas application.
    #
    # @return [Nylas::Events] Event resources for your Nylas application
    def events
      Events.new(self)
    end

    # The auth resources for your Nylas application.
    #
    # @return [Nylas::Auth] Auth resources for your Nylas application.
    def auth
      Auth.new(self)
    end

    # The webhook resources for your Nylas application.
    #
    # @return [Nylas::Webhooks] Webhook resources for your Nylas application.
    def webhooks
      Webhooks.new(self)
    end
  end
end
