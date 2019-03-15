# frozen_string_literal: true

module Nylas
  # Representation of the accounts for Account management purposes.
  # @see https://docs.nylas.com/reference#account-management
  class Account
    include Model
    self.listable = true
    self.showable = true

    attribute :id, :string
    attribute :account_id, :string
    attribute :billing_state, :string
    attribute :sync_state, :string

    attribute :email, :string
    attribute :trial, :boolean

    def upgrade
      response = execute(method: :post, path: "#{resource_path}/upgrade")
      response[:success]
    end

    def downgrade
      response = execute(method: :post, path: "#{resource_path}/downgrade")
      response[:success]
    end

    def revoke_all(keep_access_token: nil)
      payload = JSON.dump(keep_access_token: keep_access_token) if keep_access_token

      response = execute(method: :post, path: "#{resource_path}/revoke-all", payload: payload)
      response[:success]
    end

    def self.resources_path(api:)
      "/a/#{api.app_id}/accounts"
    end
  end
end
