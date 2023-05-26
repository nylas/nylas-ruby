# frozen_string_literal: true

require_relative "resources/calendars"

module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects
  class Client
    attr_reader :api_key, :host, :client_id, :client_secret

    def initialize(api_key: nil, client_id: nil, client_secret: nil)
      @api_key = api_key
      @client_id = client_id
      @client_secret = client_secret
      @host = "https://api-staging.us.nylas.com/v3"
    end

    def calendars
      Calendars.new(self)
    end

    def events
      Events.new(self)
    end
  end
end
