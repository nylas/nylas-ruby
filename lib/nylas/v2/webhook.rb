# frozen_string_literal: true

module Nylas::V2::WebhookState
  # Module representing the possible 'state' values in a Webhook
  # @see https://developer.nylas.com/docs/api#post/a/client_id/webhooks

  ACTIVE = "active"
  INACTIVE = "inactive"
end

module Nylas::V2:WebhookTrigger
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

module Nylas::V2
  # Represents a webhook attached to your application.
  # @see https://docs.nylas.com/reference#webhooks
  class Webhook
    require "openssl"
    include Model
    self.creatable = true
    self.listable = true
    self.showable = true
    self.updatable = true
    self.destroyable = true
    self.auth_method = HttpClient::AuthMethod::BASIC
    attribute :id, :string, read_only: true
    attribute :application_id, :string, read_only: true

    attribute :callback_url, :string
    attribute :state, :string
    attribute :version, :string, read_only: true
    has_n_of_attribute :triggers, :string

    STATE = [:inactive].freeze

    def save
      result = if persisted?
                 update_call(update_payload)
               else
                 create
               end

      attributes.merge(result)
    end

    def save_all_attributes
      save
    end

    def update(**data)
      raise ArgumentError, "Only 'state' is allowed to be updated" if data.length > 1 || !data.key?(:state)

      attributes.merge(**data)
      payload = JSON.dump(data)
      update_call(payload)

      true
    end

    def update_all_attributes(**data)
      update(**data)
    end

    def self.resources_path(api:)
      "/a/#{api.app_id}/webhooks"
    end

    # Verify incoming webhook signature came from Nylas
    # @param nylas_signature [str] The signature to verify
    # @param raw_body [str] The raw body from the payload
    # @param client_secret [str] Client secret of the app receiving the webhook
    # @return [Boolean] True if the webhook signature was verified from Nylas
    def self.verify_webhook_signature(nylas_signature, raw_body, client_secret)
      digest = OpenSSL::HMAC.hexdigest("SHA256", client_secret, raw_body)
      digest == nylas_signature
    end

    private

    def update_payload
      JSON.dump({ state: state })
    end
  end
end
