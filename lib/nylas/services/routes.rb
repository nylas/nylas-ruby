# frozen_string_literal: true

# Collection of helpful routes to be integrated into Ruby servers to simplify integration with Nylas
module Nylas
  # This is an Enum representing the default paths the Nylas backend middlewares
  # and frontend SDKs are preconfigured to
  module DefaultPaths
    BUILD_AUTH_URL = "/nylas/generate-auth-url"
    EXCHANGE_CODE_FOR_TOKEN = "/nylas/exchange-mailbox-token"
    WEBHOOKS = "/nylas/webhook"
  end

  # Collection of helpful routes to be integrated into Ruby servers to simplify integration with Nylas
  class Routes
    attr_accessor :api

    # @param api [Nylas::API]
    # @return [Nylas::Routes]
    def initialize(api)
      self.api = api
    end

    # Build the URL for authenticating users to your application via Hosted Authentication
    # @param scopes [Array<String>] Authentication scopes to request from the authenticating user
    # @param email_address [String] The user's email address
    # @param success_url [String] The URI to which the user will be redirected once authentication completes
    # @param client_uri [String] The route of the client
    # @param state [String] An optional arbitrary string that is returned as a URL param in your redirect URI
    # @return [String] The URL for hosted authentication
    def build_auth_url(scopes:, email_address:, success_url: "", client_uri: "", state: nil)
      api.authentication_url(
        redirect_uri: client_uri + success_url,
        scopes: scopes,
        login_hint: email_address,
        state: state
      )
    end

    # Exchange an authorization code for an access token
    # @param code [String] One-time authorization code from Nylas
    # @return [Hash] The object containing the access token and other information
    def exchange_code_for_token(code)
      api.exchange_code_for_token(code, return_full_response: true)
    end

    # Verify incoming webhook signature came from Nylas
    # @param nylas_signature [String] The signature to verify
    # @param raw_body [String] The raw body from the payload
    # @return [Boolean] True if the webhook signature was verified from Nylas
    def verify_webhook_signature(nylas_signature, raw_body)
      nylas_signature == OpenSSL::HMAC.hexdigest("SHA256", api.client.app_secret, raw_body)
    end
  end
end
