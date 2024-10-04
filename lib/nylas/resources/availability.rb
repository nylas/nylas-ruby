# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Messages API
  class Availability < Resource
    include ApiOperations::Get

    # Return availabilities for a configuration.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String)] The list of configurations, API Request ID,
    # and next cursor.
    def list(query_params: nil)
      get_list(
        path: "#{api_uri}/v3/scheduling/availability",
        query_params: query_params
      )
    end
  end
end
