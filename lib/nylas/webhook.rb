module Nylas
  # Represents a webhook attached to your application.
  # @see https://docs.nylas.com/reference#webhooks
  class Webhook
    include Model
    allows_operations(listable: true, showable: true)
    attribute :id, :string
    attribute :application_id, :string

    attribute :callback_url, :string
    attribute :state, :string
    attribute :version, :string
    has_n_of_attribute :triggers, :string

    def self.resources_path(api:)
      "/a/#{api.app_id}/webhooks"
    end
  end
end
