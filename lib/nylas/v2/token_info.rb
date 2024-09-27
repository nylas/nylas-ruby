# frozen_string_literal: true

module Nylas::V2
  # Structure to represent information about a Nylas access token.
  # @see https://developer.nylas.com/docs/api/#post/a/client_id/accounts/id/token-info
  class TokenInfo
    include Model::Attributable

    attribute :scopes, :string
    attribute :state, :string
    attribute :created_at, :unix_timestamp
    attribute :updated_at, :unix_timestamp

    # Returns the state of the token as a boolean
    # @return [Boolean] If the token is active
    def valid?
      state == "valid"
    end
  end
end
