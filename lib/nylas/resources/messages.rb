# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Messages API
  class Messages < Resource
    include ApiOperations::Get
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all messages.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of messages and API Request ID.
    def list(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages",
        query_params: query_params
      )
    end

    # Return a message.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param message_id [String] The id of the message to return.
    #   Use "primary" to refer to the primary message associated with grant.
    # @return [Array(Hash, String)] The message and API request ID.
    def find(identifier:, message_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      )
    end

    # Updates a message.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param message_id [String] The id of the message to update.
    #   Use "primary" to refer to the primary message associated with grant.
    # @param request_body [Hash] The values to update the message with
    # @return [Array(Hash, String)] The updated message and API Request ID.
    def update(identifier:, message_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}",
        request_body: request_body
      )
    end

    # Deletes a message.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param message_id [String] The id of the message to delete.
    #   Use "primary" to refer to the primary message associated with grant.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, message_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      )

      [true, request_id]
    end
  end
end
