# frozen_string_literal: true

module Nylas
  # Representation of the accounts for Account management purposes.
  # @see https://docs.nylas.com/reference#account-management
  class Account
    include Model
    self.listable = true
    self.showable = true
    self.updatable = true
    self.destroyable = true
    self.auth_method = HttpClient::AuthMethod::BASIC

    attribute :id, :string, read_only: true
    attribute :account_id, :string, read_only: true
    attribute :billing_state, :string, read_only: true
    attribute :sync_state, :string, read_only: true
    attribute :provider, :string, read_only: true
    attribute :authentication_type, :string, read_only: true

    attribute :email, :string, read_only: true
    attribute :trial, :boolean, read_only: true
    attribute :metadata, :hash

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

    # Return information about an account's access token
    # @param access_token [String] The access token to inquire about
    # @return [TokenInfo] The access token information
    def token_info(access_token)
      payload = JSON.dump(access_token: access_token)
      response = execute(method: :post, path: "#{resource_path}/token-info", payload: payload)
      TokenInfo.new(**response)
    end

    def self.resources_path(api:)
      "/a/#{api.app_id}/accounts"
    end
  end
end
