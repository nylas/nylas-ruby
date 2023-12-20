# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Module representing the possible 'trigger' values in a Webhook.
  # @see https://developer.nylas.com/docs/api#post/a/client_id/webhooks
  module WebhookTrigger
    CALENDAR_CREATED = "calendar.created"
    CALENDAR_UPDATED = "calendar.updated"
    CALENDAR_DELETED = "calendar.deleted"
    EVENT_CREATED = "event.created"
    EVENT_UPDATED = "event.updated"
    EVENT_DELETED = "event.deleted"
    GRANT_CREATED = "grant.created"
    GRANT_UPDATED = "grant.updated"
    GRANT_DELETED = "grant.deleted"
    GRANT_EXPIRED = "grant.expired"
    MESSAGE_SEND_SUCCESS = "message.send_success"
    MESSAGE_SEND_FAILED = "message.send_failed"
    MESSAGE_OPENED = "message.opened"
    MESSAGE_LINK_CLICKED = "message.link_clicked"
    THREAD_REPLIED = "thread.replied"
  end

  # Nylas Webhooks API
  class Webhooks < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all webhooks.
    #
    # @return [Array(Array(Hash), String)] The list of webhooks and API Request ID.
    def list
      get(
        path: "#{api_uri}/v3/webhooks"
      )
    end

    # Return a webhook.
    #
    # @param webhook_id [String] The id of the webhook to return.
    # @return [Array(Hash, String)] The webhook and API request ID.
    def find(webhook_id:)
      get(
        path: "#{api_uri}/v3/webhooks/#{webhook_id}"
      )
    end

    # Create a webhook.
    #
    # @param request_body [Hash] The values to create the webhook with.
    # @return [Array(Hash, String)] The created webhook and API Request ID.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/webhooks",
        request_body: request_body
      )
    end

    # Update a webhook.
    #
    # @param webhook_id [String] The id of the webhook to update.
    # @param request_body [Hash] The values to update the webhook with
    # @return [Array(Hash, String)] The updated webhook and API Request ID.
    def update(webhook_id:, request_body:)
      put(
        path: "#{api_uri}/v3/webhooks/#{webhook_id}",
        request_body: request_body
      )
    end

    # Delete a webhook.
    #
    # @param webhook_id [String] The id of the webhook to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(webhook_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/webhooks/#{webhook_id}"
      )

      [true, request_id]
    end
  end
end
