# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  module WebhookTrigger
    # Module representing the possible 'trigger' values in a Webhook
    # @see https://developer.nylas.com/docs/api#post/a/client_id/webhooks

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
  end

  # Webhooks
  class Webhooks < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(parent)
      super("webhooks", parent)
    end

    # Create a webhook
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The created webhook object and API Request ID
    def create(path_params: {}, query_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Find a webhook
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Hash, String)] The webhook object and API Request ID
    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    # List all webhooks
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(Array, String)] The list of webhooks and API Request ID
    def list(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    # Update a webhook
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @param request_body [Hash] The request body to pass to the request
    # @return [Array(Hash, String)] The updated webhook object and API Request ID
    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    # Delete a webhook
    # @param path_params [Hash] The path params to pass to the request
    # @param query_params [Hash] The query params to pass to the request
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation
    def destroy(path_params: {}, query_params: {})
      _, request_id = delete(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )

      [true, request_id]
    end
  end
end
