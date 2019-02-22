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

    def revoke_all
      response = execute(method: :post, path: "#{resource_path}/revoke-all")
      response[:success]
    end

    def self.resources_path(api:)
      "/a/#{api.app_id}/accounts"
    end
  end
end
