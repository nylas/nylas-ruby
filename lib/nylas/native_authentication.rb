module Nylas
  # Authenticate your application using the native interface
  # @see https://docs.nylas.com/reference#native-authentication-1
  class NativeAuthentication
    attr_accessor :api
    def initialize(api:)
      self.api = api
    end

    def authenticate(name:, email_address:, provider:, settings:, reauth_account_id: nil,
                     scopes: nil)
      scopes ||= ["email", "calendar", "contacts"]
      scopes = scopes.join(",") unless scopes.is_a?(String)
      code = retrieve_code(name: name, email_address: email_address, provider: provider,
                           settings: settings, reauth_account_id: reauth_account_id, scopes: scopes)

      exchange_code_for_access_token(code)
    end

    private def retrieve_code(name:, email_address:, provider:, settings:, reauth_account_id:, scopes: nil)
      payload = { client_id: api.client.app_id, name: name, email_address: email_address,
                  provider: provider, settings: settings, scopes: scopes }
      payload[:reauth_account_id] = reauth_account_id
      response = api.execute(method: :post, path: "/connect/authorize", payload: JSON.dump(payload))
      response[:code]
    end

    private def exchange_code_for_access_token(code)
      payload = { client_id: api.client.app_id, client_secret: api.client.app_secret, code: code }
      response = api.execute(method: :post, path: "/connect/token", payload: JSON.dump(payload))
      response[:access_token]
    end
  end
end
