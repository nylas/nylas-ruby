# frozen_string_literal: true

module Nylas
  # Build a Rack middleware binding with routes for:
  #  1. '/nylas/generate-auth-url': Building the URL for authenticating users to your app via Hosted Auth
  #  2. '/nylas/exchange-mailbox-token': Exchange an authorization code for an access token
  class RackBinding
    # @param app [Rack::Builder] The Rack app
    # @param nylas [Nylas::API] The configured Nylas API client
    # @param default_scopes [Array<String>] Authentication scopes to request from the authenticating user
    # @param exchange_mailbox_token_callback [Method] The callback method that takes the access token response
    #   and returns an API value
    # @param client_uri [String] The route of the client
    # @param build_auth_url [String] Override URL of building the Nylas hosted auth URL
    # @param exchange_code_for_token_url [String] Override URL of exchanging the auth code for access token
    def initialize(
      app,
      nylas,
      default_scopes,
      exchange_mailbox_token_callback,
      client_uri: nil,
      build_auth_url: nil,
      exchange_code_for_token_url: nil
    )
      @app = app
      @nylas = nylas
      @nylas_routes = Nylas::Routes.new(nylas)
      @default_scopes = default_scopes
      @exchange_mailbox_token_callback = exchange_mailbox_token_callback
      @client_uri = client_uri || ""
      @build_auth_url = build_auth_url || Nylas::DefaultPaths::BUILD_AUTH_URL
      @exchange_code_for_token_url =
        exchange_code_for_token_url || Nylas::DefaultPaths::EXCHANGE_CODE_FOR_TOKEN
    end

    def call(env)
      request = Rack::Request.new(env)

      if env["PATH_INFO"] == @build_auth_url
        build_auth_url(JSON.parse(request.body.read))
      elsif env["PATH_INFO"] == @exchange_code_for_token_url
        exchange_code_for_token(JSON.parse(request.body.read))
      else
        @app.call(env)
      end
    end

    private

    def build_auth_url(params)
      url = @nylas_routes.build_auth_url(
        scopes: @default_scopes,
        email_address: params["email_address"] || "",
        success_url: params["success_url"] || "",
        client_uri: @client_uri
      )

      [200, { "Content-Type" => "text/plain" }, [url]]
    end

    def exchange_code_for_token(params)
      access_token = @nylas_routes.exchange_code_for_token(params["token"])

      if @exchange_mailbox_token_callback.respond_to? :call
        @exchange_mailbox_token_callback.call(access_token)
      else
        [200, { "Content-Type" => "application/json" }, [access_token.to_json]]
      end
    end
  end
end
