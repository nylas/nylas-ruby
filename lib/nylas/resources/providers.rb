# frozen_string_literal: true

require_relative "resource"

module Nylas
  # Providers
  class Providers < Resource
    def initialize(parent, client_id, client_secret)
      super("providers", parent)
      if client_id.nil? || client_secret.nil?
        raise "You must provide a client_id and client_secret to use provider methods"
      end

      @client_id = client_id
      @client_secret = client_secret
    end

    attr_reader :client_id, :client_secret

    # Lists created providers (integrations)
    # @return [Array(Array, String)] List of created providers and API Request ID
    def list
      get(
        "#{host}/connect/providers/find",
        query_params: { client_id: client_id }
      )
    end

    # Detects provider for passed email
    # @param [Hash] query_params The query parameters to pass to the API
    # @return [Array(Hash, String)] The detected provider object and API Request ID
    def detect(query_params)
      post(
        "#{host}/connect/providers/detect",
        query_params: { client_id: client_id, **query_params }
      )
    end
  end
end
