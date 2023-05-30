# frozen_string_literal: true

require_relative "base_resource"
require_relative "grants"
require_relative "providers"
require_relative "../operations/http_client"

module Nylas
  class Auth < BaseResource
    include HttpClient

    def initialize(sdk_instance)
      super("auth", sdk_instance)
    end

    def providers
      Providers.new(self)
    end

    def grants
      Grants.new(self)
    end

    def check_auth_credentials
      return unless client_id.nil? || client_secret.nil?

      raise "You must provide a client_id and client_secret to use auth methods"
    end

    def exchange_code_for_token(code, redirect_uri, code_verifier: nil)
      path = "#{host}/connect/token"
      payload = { client_id: client_id, client_secret: client_secret, code: code, redirect_uri: redirect_uri,
                  grant_type: "authorization_code" }

      payload[:code_verifier] = code_verifier if code_verifier

      post(path: path, payload: payload, api_key: api_key)
    end

    def refresh_access_token(refresh_token, redirect_uri)
      check_auth_credentials

      path = "#{host}/connect/token"

      payload = { client_id: client_id, client_secret: client_secret, refresh_token: refresh_token,
                  redirect_uri: redirect_uri, grant_type: "refresh_token" }

      post(path: path, payload: payload, api_key: api_key)
    end
  end
end
