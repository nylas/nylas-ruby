# frozen_string_literal: true

module Nylas
  # Represents a webhook attached to your application.
  # @see https://docs.nylas.com/reference#webhooks
  class Webhook
    include Model
    allows_operations(creatable: true, listable: true, showable: true, updatable: true,
                      destroyable: true)
    attribute :id, :string, read_only: true
    attribute :application_id, :string, read_only: true

    attribute :callback_url, :string
    attribute :state, :string
    attribute :version, :string, read_only: true
    has_n_of_attribute :triggers, :string

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

    private

    def update_payload
      JSON.dump({ state: state })
    end
  end
end
