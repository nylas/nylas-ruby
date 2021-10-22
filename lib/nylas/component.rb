# frozen_string_literal: true

module Nylas
  # Structure to represent a the Component Schema.
  class Component
    include Model
    allows_operations(creatable: true, listable: true, filterable: true, showable: true, updatable: true,
                      destroyable: true)

    attribute :id, :string
    attribute :account_id, :string
    attribute :name, :string
    attribute :type, :string
    attribute :action, :integer
    attribute :active, :boolean
    attribute :settings, :hash
    attribute :public_account_id, :string
    attribute :public_token_id, :string
    attribute :public_application_id, :string
    attribute :access_token, :string
    attribute :created_at, :date
    attribute :updated_at, :date

    has_n_of_attribute :allowed_domains, :string

    def initialize(**initial_data)
      super(**initial_data)
    end

    def resources_path(*)
      "/component/#{api.client.app_id}"
    end
  end
end
