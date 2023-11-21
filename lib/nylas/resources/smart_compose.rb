# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Smart Compose API
  class SmartCompose < Resource
    include ApiOperations::Post

    # Compose a message.
    #
    # @param identifier [String] Grant ID or email account to generate a message suggestion for.
    # @param request_body [Hash] The prompt that smart compose will use to generate a message suggestion.
    # @return [Array(Hash, String)] The generated message and API Request ID.
    def compose_message(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/smart-compose",
        request_body: request_body
      )
    end

    # Compose a message reply.
    #
    # @param identifier [String] Grant ID or email account to generate a message suggestion for.
    # @param message_id [String] The id of the message to reply to.
    # @param request_body [Hash] The prompt that smart compose will use to generate a message reply.
    # @return [Array(Hash, String)] The generated message reply and API Request ID.
    def compose_message_reply(identifier:, message_id:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}/smart-compose",
        request_body: request_body
      )
    end
  end
end
