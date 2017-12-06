require 'nylas/restful_model'

module Nylas
  class Account < RestfulModel
    parameter :email
    parameter :trial
    parameter :trial_expires
    parameter :sync_state
    parameter :billing_state

    def _perform_account_action!(action)
      raise UnexpectedAccountAction.new unless action == "upgrade" || action == "downgrade"

      collection = ManagementModelCollection.new(Account, @_api, {:account_id=>account_id})
      url = "#{collection.url}/#{account_id}/#{action}"
      @_api.post(url,{}) do |response, _request, result|
          # Throw any exceptions
        Nylas.interpret_response(result, response, expected_class: Object)
      end
    end

    def upgrade!
      _perform_account_action!('upgrade')
    end

    def downgrade!
      _perform_account_action!('downgrade')
    end
  end
end
