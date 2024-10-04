# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Messages API
  class Sessions < Resource
    include ApiOperations::Post
    include ApiOperations::Delete

    # Create a session for a configuration.
    # @param request_body [Hash] The values to create a configuration sessions.
    # @return [Array(Hash, String)] The created configuration and API Request ID.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/scheduling/sessions",
        request_body: request_body
      )
    end

    # Delete a session for a configuration.
    # @param session_id [String] The id of the session to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(session_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/scheduling/sessions/#{session_id}"
      )

      [true, request_id]
    end
  end
end
