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

    def initialize(sdk_instance)
      super("auth", sdk_instance)

      @grants = Grants.new(sdk_instance)
    end

    attr_reader :grants

    # Build the URL for authenticating users to your application with OAuth 2.0
    # @param config [Hash] The configuration for building the URL
    # @return [String] The URL for hosted authentication
    def url_for_oauth2(config)
      url_auth_builder(config).to_s
    end

    # Exchange an authorization code for an access token
    # @param request [Hash] The code exchange request
    # @return [Array(Hash, String)] The token object and API Request ID
    def exchange_code_for_token(request)
      request[:grant_type] = "authorization_code"

      post(
        path: "#{host}/v3/connect/token",
        request_body: request.to_json
      )
    end

    # Refresh an access token
    # @param request [Hash] The code exchange request
    # @return [Array(Hash, String]) The refreshed token object and API Request ID
    def refresh_access_token(request)
      request[:grant_type] = "refresh_token"

      post(
        path: "#{host}/v3/connect/token",
        request_body: request.to_json
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

    # Revoke a single access token
    # @param token [String] The access token to revoke
    # @return [Boolean] True if the access token was revoked successfully
    def revoke(token)
      post(
        path: "#{host}/v3/connect/revoke",
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
      builder.path = "/v3/connect/auth"
      builder.query = build_query(config)

      builder
    end

    def build_query(config)
      params = {
        "client_id" => config[:client_id],
        "redirect_uri" => config[:redirect_uri],
        "access_type" => config[:access_type] || "online",
        "response_type" => "code"
      }

      params["provider"] = config[:provider] if config[:provider]
      if config[:login_hint]
        params["login_hint"] = config[:login_hint]
        params["include_grant_scopes"] = config[:include_grant_scopes].to_s if config[:include_grant_scopes]
      end
      params["scope"] = config[:scope].join(" ") if config[:scope]
      params["prompt"] = config[:prompt] if config[:prompt]
      params["metadata"] = config[:metadata] if config[:metadata]
      params["state"] = config[:state] if config[:state]

      URI.encode_www_form(params)
    end

    def hash_pkce_secret(secret)
      Digest::SHA256.digest(secret).unpack1("H*")
      Base64.strict_encode64(Digest::SHA256.digest(secret))
    end
  end
end
