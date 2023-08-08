# frozen_string_literal: true

require "digest"
require "base64"
require "securerandom"
require "ostruct"
require "uri"

require_relative "resource"
require_relative "grants"
require_relative "../handler/api_operations"

module Nylas
  # Auth
  class Auth < Resource
    include ApiOperations::Post
    include ApiOperations::Get

    def initialize(sdk_instance, client_id, client_secret)
      super("auth", sdk_instance)
      if client_id.nil? || client_secret.nil?
        raise "You must provide a client_id and client_secret to use auth methods"
      end

      @grants = Grants.new(sdk_instance)
      @client_id = client_id
      @client_secret = client_secret
    end

    attr_reader :grants, :client_id, :client_secret

    # Build the URL for authenticating users to your application with OAuth 2.0
    # @param config [Hash] The configuration for building the URL
    # @return [String] The URL for hosted authentication
    def url_for_oauth2(config)
      url_auth_builder(config).to_s
    end

    # Exchange an authorization code for an access token
    # @param code [String] The OAuth 2.0 code from the authorization request
    # @param redirect_uri [String] The redirect URI of the integration
    # @param code_verifier [String] The code verifier used to generate the code challenge
    # @return [Array(Hash, String)] The token object and API Request ID
    def exchange_code_for_token(code, redirect_uri, code_verifier: nil)
      payload = { client_id: client_id, client_secret: client_secret, code: code, redirect_uri: redirect_uri,
                  grant_type: "authorization_code" }

      payload[:code_verifier] = code_verifier if code_verifier

      post(
        path: "#{host}/connect/token",
        request_body: payload
      )
    end

    # Refresh an access token
    # @param refresh_token [String] The refresh token from the original access token
    # @param redirect_uri [String] The redirect URI of the integration
    # @return [Array(Hash, String]) The refreshed token object and API Request ID
    def refresh_access_token(refresh_token, redirect_uri)
      payload = { client_id: client_id, client_secret: client_secret, refresh_token: refresh_token,
                  redirect_uri: redirect_uri, grant_type: "refresh_token" }

      post(
        path: "#{host}/connect/token",
        request_body: payload
      )
    end

    # Build the URL for authenticating users to your application with OAuth 2.0 and PKCE
    # IMPORTANT: YOU WILL NEED TO STORE THE 'secret' returned to use it inside the CodeExchange flow
    # @param config [Hash] The configuration for building the URL
    # @return [OpenStruct] The URL for hosted authentication with secret & hashed secret
    def url_for_oauth2_pkce(config)
      url = url_auth_builder(config)

      # Generate a secret and hash it
      secret = SecureRandom.uuid
      secret_hash = hash_pkce_secret(secret)

      # Add code challenge to URL generation
      url.query = build_query_with_pkce(config, secret_hash)

      # Return the url with secret & hashed secret
      OpenStruct.new(secret: secret, secret_hash: secret_hash, url: url.to_s)
    end

    # Build the URL for admin consent authentication for Microsoft
    # @param config [Hash] The configuration for the authentication request
    # @return [String] The URL for hosted authentication
    def url_for_admin_consent(config)
      config_with_provider = config.merge("provider" => "microsoft")
      url = url_auth_builder(config_with_provider)

      query_params = build_query_with_admin_consent(config)
      url.query = URI.encode_www_form(query_params)

      url.to_s
    end

    # Create a new authorization request and get a new unique login url.
    # Used only for hosted authentication.
    # This is the initial step requested from the server side to issue a new login url.
    # @param payload [Hash] The configuration for the authentication request
    # @return [Array(Hash, String)] The authorization request object and API Request ID
    def server_side_hosted_auth(payload)
      credentials = "#{client_id}:#{client_secret}"
      encoded_credentials = Base64.strict_encode64(credentials)

      post(
        path: "#{host}/connect/auth",
        request_body: payload,
        headers: { "Authorization" => "Basic #{encoded_credentials}" }
      )
    end

    # Revoke a single access token
    # @param token [String] The access token to revoke
    # @return [Boolean] True if the access token was revoked successfully
    def revoke(token)
      post(
        path: "#{host}/connect/revoke",
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
      params["response_type"] = "adminconsent"
      params["credential_id"] = config["credentialId"]

      params
    end

    def build_query_with_pkce(config, secret_hash)
      params = build_query(config)

      # Append new PKCE specific params
      params["code_challenge_method"] = "s256"
      params["code_challenge"] = secret_hash

      URI.encode_www_form(params)
    end

    def url_auth_builder(config)
      builder = URI.parse(host)
      builder.path = "/connect/auth"
      builder.query = build_query(config)

      builder
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
