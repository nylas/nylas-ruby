# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  # Providers
  class Providers < BaseResource
    include Operations::Get
    include Operations::Post

    def initialize(parent)
      super("providers", parent)
    end

    # Lists created providers (integrations)
    # @return [Array(Array, String)] List of created providers and API Request ID
    def list
      check_credentials

      get(
        "#{host}/connect/providers/find",
        query_params: { client_id: client_id }
      )
    end

    # Detects provider for passed email
    # @param [Hash] query_params The query parameters to pass to the API
    # @return [Array(Hash, String)] The detected provider object and API Request ID
    def detect(query_params)
      check_credentials

      post(
        "#{host}/connect/providers/detect",
        query_params: { client_id: client_id, **query_params }
      )
    end

    private

    def check_credentials
      raise "client_id is required" if client_id.nil?
    end
  end
end
