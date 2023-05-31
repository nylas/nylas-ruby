# frozen_string_literal: true

require "digest"
require "base64"
require "securerandom"
require "ostruct"
require "uri"

require_relative "base_resource"
require_relative "grants"
require_relative "providers"
require_relative "../handler/api_operations"

module Nylas
  # Auth
  class Auth < BaseResource
    include Operations::Post
    include Operations::Get

    def initialize(sdk_instance)
      super("auth", sdk_instance)
      @providers = Providers.new(@sdk_instance)
      @grants = Grants.new(@sdk_instance)
    end

    attr_reader :providers, :grants

    # Exchange an authorization code for an access token
    # @param payload The request parameters for the code exchange
    # @return Information about the Nylas application
    def exchange_code_for_token(code, redirect_uri, code_verifier: nil)
      payload = { client_id: client_id, client_secret: client_secret, code: code, redirect_uri: redirect_uri,
                  grant_type: "authorization_code" }

      payload[:code_verifier] = code_verifier if code_verifier

      post(
        "#{host}/connect/token",
        request_body: payload
      )
    end

    def refresh_access_token(refresh_token, redirect_uri)
      check_auth_credentials

      payload = { client_id: client_id, client_secret: client_secret, refresh_token: refresh_token,
                  redirect_uri: redirect_uri, grant_type: "refresh_token" }

      post(
        "#{host}/connect/token",
        request_body: payload
      )
    end

    def validate_id_token(token)
      validate_token({ id_token: token })
    end

    def validate_access_token(token)
      validate_token({ access_token: token })
    end

    def url_for_authentication(config)
      url_auth_builder(config).to_s
    end

    def url_for_authentication_pkce(config)
      url = url_auth_builder(config)

      # Add code challenge to URL generation
      url.query = build_query_with_pkce(config)

      secret = SecureRandom.uuid
      secret_hash = hash_pkce_secret(secret)

      # Return the url with secret & hashed secret
      OpenStruct.new(secret: secret, secret_hash: secret_hash, url: url.to_s)
    end

    def url_for_admin_consent(config)
      config_with_provider = config.merge("provider" => "microsoft")
      url = url_auth_builder(config_with_provider)

      query_params = build_query_with_admin_consent(config)
      url.query = URI.encode_www_form(query_params)

      url.to_s
    end

    def hosted_auth(payload)
      check_auth_credentials

      credentials = "#{client_id}:#{client_secret}"
      encoded_credentials = Base64.strict_encode64(credentials)

      post(
        "#{host}/connect/auth",
        request_body: payload,
        headers: { "Authorization" => "Basic #{encoded_credentials}" }
      )
    end

    def revoke(token)
      post(
        "#{host}/connect/revoke",
        query_params: {
          token: token
        }
      )
      true
    end

    private

    def build_query_with_admin_consent(config)
      params = build_query(config)

      # Append new params specific for admin consent
      params << %w[response_type adminconsent]
      params << ["credential_id", config["credentialId"]]

      params
    end

    def check_auth_credentials
      return unless client_id.nil? || client_secret.nil?

      raise "You must provide a client_id and client_secret to use auth methods"
    end

    def build_query_with_pkce(config)
      params = build_query(config)

      # Append new PKCE specific params
      params << %w[code_challenge_method s256]

      secret = SecureRandom.uuid
      secret_hash = hash_pkce_secret(secret)
      params << ["code_challenge", secret_hash]

      URI.encode_www_form(params)
    end

    def validate_token(query_params)
      check_auth_credentials
      get(
        "#{host}/connect/tokeninfo",
        query_params: query_params
      )
    end

    def url_auth_builder(config)
      check_auth_credentials

      URI::HTTP.build(
        host: host,
        path: "/connect/auth",
        query: build_query(config)
      )
    end

    def build_query(config)
      params = {
        "client_id" => client_id,
        "redirect_uri" => config["redirectUri"],
        "access_type" => config["accessType"] || "offline",
        "response_type" => "code"
      }

      params["provider"] = config["provider"] if config["provider"]
      if config["loginHint"]
        params["login_hint"] = config["loginHint"]
        params["include_grant_scopes"] = config["includeGrantScopes"].to_s if config["includeGrantScopes"]
      end
      params["scope"] = config["scope"].join(" ") if config["scope"]
      params["prompt"] = config["prompt"] if config["prompt"]
      params["metadata"] = config["metadata"] if config["metadata"]
      params["state"] = config["state"] if config["state"]

      URI.encode_www_form(params)
    end

    def hash_pkce_secret(secret)
      Digest::SHA256.digest(secret).unpack1("H*")
      Base64.strict_encode64(Digest::SHA256.digest(secret))
    end
  end
end
