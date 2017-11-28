require_relative 'restful_model'

module Nylas
  module V1
    # api_account.rb --- functions related to the /account endpoint.
    # not to be confused with account.rb which is used by the hosted API
    # account management endpoint.
    class APIAccount < RestfulModel
      parameter :name
      parameter :email_address
      parameter :provider
      parameter :organization_unit
      parameter :sync_state

      def self.collection_name
        "accounts"
      end
    end
  end
end
