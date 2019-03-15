# frozen_string_literal: true

module Nylas
  # Ruby representation of the Nylas /account API
  # @see https://docs.nylas.com/reference#account
  class CurrentAccount
    include Model
    self.showable = true

    self.resources_path = "/account"

    attribute :id, :string
    attribute :object, :string, default: "account"

    attribute :account_id, :string
    attribute :email_address, :string
    attribute :name, :string
    attribute :organization_unit, :string
    attribute :provider, :string
    attribute :sync_state, :string
    attribute :linked_at, :unix_timestamp
  end
end
