# api_account.rb --- functions related to the /account endpoint.
# not to be confused with account.rb which is used by the hosted API
# account management endpoint.
require 'restful_model'

module Inbox
  class APIAccount < RestfulModel

    parameter :account_id
    parameter :email_address
    parameter :id
    parameter :name
    parameter :object
    parameter :organization_unit
    parameter :provider

    def self.collection_name
      "accounts"
    end
  end
end
