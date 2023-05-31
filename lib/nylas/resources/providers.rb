# frozen_string_literal: true

require_relative "base_resource"
require_relative "../operations/api_operations"

module Nylas
  # Providers
  class Providers < BaseResource
    include Operations::Get
    include Operations::Post

    def initialize(parent)
      super("providers", parent)
    end

    def check_credentials
      raise "client_id is required" if client_id.nil?
    end

    def list
      check_credentials

      get(
        "#{host}/connect/providers/find",
        query_params: { client_id: client_id },
        api_key: api_key
      )
    end

    def detect(query_params)
      check_credentials

      post(
        "#{host}/connect/providers/detect",
        query_params: { client_id: client_id, **query_params },
        api_key: api_key
      )
    end
  end
end
