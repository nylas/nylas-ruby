# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  module WebhookTrigger
    # Module representing the possible 'trigger' values in a Webhook
    # @see https://developer.nylas.com/docs/api#post/a/client_id/webhooks

    ACCOUNT_CONNECTED = "account.connected"
    ACCOUNT_RUNNING = "account.running"
    ACCOUNT_STOPPED = "account.stopped"
    ACCOUNT_INVALID = "account.invalid"
    ACCOUNT_SYNC_ERROR = "account.sync_error"
    MESSAGE_CREATED = "message.created"
    MESSAGE_OPENED = "message.opened"
    MESSAGE_LINK_CLICKED = "message.link_clicked"
    MESSAGE_UPDATED = "message.updated"
    MESSAGE_BOUNCED = "message.bounced"
    THREAD_REPLIED = "thread.replied"
    CONTACT_CREATED = "contact.created"
    CONTACT_UPDATED = "contact.updated"
    CONTACT_DELETED = "contact.deleted"
    CALENDAR_CREATED = "calendar.created"
    CALENDAR_UPDATED = "calendar.updated"
    CALENDAR_DELETED = "calendar.deleted"
    EVENT_CREATED = "event.created"
    EVENT_UPDATED = "event.updated"
    EVENT_DELETED = "event.deleted"
    JOB_SUCCESSFUL = "job.successful"
    JOB_FAILED = "job.failed"
    JOB_DELAYED = "job.delayed"
    JOB_CANCELLED = "job.cancelled"
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

    def create(query_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    def list(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def destroy(path_params: {}, query_params: {})
      delete(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end
  end
end
