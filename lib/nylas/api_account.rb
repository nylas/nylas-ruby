# api_account.rb --- functions related to the /account endpoint.
# not to be confused with account.rb which is used by the hosted API
# account management endpoint.
require 'nylas/restful_model'

module Nylas
  class APIAccount < RestfulModel

    parameter :account_id
    parameter :email_address
    parameter :id
    parameter :name
    parameter :object
    parameter :organization_unit
    parameter :provider
    parameter :sync_state

    def self.collection_name
      "accounts"
    end
  end
end
