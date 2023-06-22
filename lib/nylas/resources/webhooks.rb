# frozen_string_literal: true

require_relative "resource"
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
  class Webhooks < Resource
    include Operations::Create
    include Operations::Update
    include Operations::List
    include Operations::Destroy
    include Operations::Find

    def initialize(parent)
      super("webhooks", parent)
    end
  end
end
