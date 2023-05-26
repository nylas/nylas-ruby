# frozen_string_literal: true

require_relative "resources/calendars"

module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects
  class Client
    attr_reader :api_key, :host

    def initialize(api_key, client_id, client_secret)
      @api_key = api_key
      @client_id = client_id
      @client_secret = client_secret
    end

    def calendars
      Calendars.new(self)
    end

    def events
      Events.new(self)
    end
  end
end
