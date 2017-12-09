module Nylas
  # Ruby representation of the Nylas /account API
  # @see https://docs.nylas.com/reference#account
  class CurrentAccount
    include Model

    self.read_only = true
    self.searchable = false
    self.collectionable = false

    self.resources_path = "/account"

    attribute :id, :string
    attribute :object, :string, default: "account"

    attribute :account_id, :string
    attribute :email_address, :string
    attribute :name, :string
    attribute :organization_unit, :string
    attribute :provider, :string
    attribute :sync_state, :string
  end
end
