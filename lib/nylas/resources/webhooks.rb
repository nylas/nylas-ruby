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

    # Update the webhook secret value for a destination.
    # @param webhook_id [String] The ID of the webhook destination to update.
    # @return [Array(Hash, String)] The updated webhook destination and API Request ID.
    def rotate_secret(webhook_id:)
      put(
        path: "#{api_uri}/v3/webhooks/#{webhook_id}/rotate-secret",
        request_body: {}
      )
    end

    # Get the current list of IP addresses that Nylas sends webhooks from
    # @return [Array(Hash, String)] List of IP addresses that Nylas sends webhooks from and API Request ID.
    def ip_addresses
      get(
        path: "#{api_uri}/v3/webhooks/ip-addresses"
      )
    end

    # Extract the challenge parameter from a URL
    # @param url [String] The URL sent by Nylas containing the challenge parameter
    # @return [String] The challenge parameter
    def self.extract_challenge_parameter(url)
      url_object = URI.parse(url)
      query = CGI.parse(url_object.query || "")

      challenge_parameter = query["challenge"]
      if challenge_parameter.nil? || challenge_parameter.empty? || challenge_parameter.first.nil?
        raise "Invalid URL or no challenge parameter found."
      end

      challenge_parameter.first
    end
  end
end
