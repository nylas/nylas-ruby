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

    # Initializes Auth.
    def initialize(sdk_instance)
      super(sdk_instance)

      @grants = Grants.new(sdk_instance)
    end

    attr_reader :grants

    # Builds the URL for authenticating users to your application with OAuth 2.0.
    #
    # @param config [Hash] Configuration for building the URL.
    # @return [String] URL for hosted authentication.
    def url_for_oauth2(config)
      url_auth_builder(config).to_s
    end

    # Exchanges an authorization code for an access token.
    #
    # @param request [Hash] Code exchange request.
    # @return [Hash] Token object.
    def exchange_code_for_token(request)
      request[:grant_type] = "authorization_code"

      execute_token_request(request)
    end

    # Refreshes an access token.
    #
    # @param request [Hash] Code exchange request.
    # @return [Hash] Refreshed token object.
    def refresh_access_token(request)
      request[:grant_type] = "refresh_token"

      execute_token_request(request)
    end

    # Builds the URL for authenticating users to your application with OAuth 2.0 and PKCE.
    #   IMPORTANT: You must store the 'secret' returned to use it inside the CodeExchange flow.
    #
    # @param config [Hash] Configuration for building the URL.
    # @return [OpenStruct] URL for hosted authentication with the secret and the hashed secret.
    def url_for_oauth2_pkce(config)
      url = url_auth_builder(config)

      # Generates a secret and hashes it.
      secret = SecureRandom.uuid
      secret_hash = hash_pkce_secret(secret)

      # Adds code challenge to URL generation.
      url.query = build_query_with_pkce(config, secret_hash)

      # Returns the URL with secret and hashed secret.
      OpenStruct.new(secret: secret, secret_hash: secret_hash, url: url.to_s)
    end

    # Builds the URL for admin consent authentication for Microsoft.
    #
    # @param config [Hash] Configuration for the authentication request.
    # @return [String] URL for hosted authentication.
    def url_for_admin_consent(config)
      config_with_provider = config.merge("provider" => "microsoft")
      url = url_auth_builder(config_with_provider)

      query_params = build_query_with_admin_consent(config)
      url.query = URI.encode_www_form(query_params)

      url.to_s
    end

    # Revokes a single access token.
    #
    # @param token [String] Access token to revoke.
    # @return [Boolean] True if the access token was revoked successfully.
    def revoke(token)
      post(
        path: "#{api_uri}/v3/connect/revoke",
        query_params: {
          token: token
        }
      )
      true
    end

    private

    # Builds the query with admin consent authentication for Microsoft.
    #
    # @param config [Hash] Configuration for the query.
    # @return [Array(Hash, String)] Updated list of parameters, including those specific to admin
    # consent.
    def build_query_with_admin_consent(config)
      params = build_query(config)

      # Appends new params specific for admin consent.
      params["response_type"] = "adminconsent"
      params["credential_id"] = config["credentialId"]

      params
    end

    # Builds the query with PKCE.
    #
    # @param config [Hash] Configuration for the query.
    # @param secret_hash [Hash] Hashed secret.
    # @return [Array(Hash, String)] Updated list of encoded parameters, including those specific
    # to PKCE.
    def build_query_with_pkce(config, secret_hash)
      params = build_query(config)

      # Appends new PKCE specific params.
      params["code_challenge_method"] = "s256"
      params["code_challenge"] = secret_hash

      URI.encode_www_form(params)
    end

    # Builds the authentication URL.
    #
    # @param config [Hash] Configuration for the query.
    # @return [Array(Hash, String)] List of components for the authentication URL.
    def url_auth_builder(config)
      builder = URI.parse(api_uri)
      builder.path = "/v3/connect/auth"
      builder.query = build_query(config)

      builder
    end

    # Builds the query.
    #
    # @param config [Hash] Configuration for the query.
    # @return [Array(Hash, String)] List of encoded parameters for the query.
    def build_query(config)
      params = {
        "client_id" => config[:config][:client_id],
        "redirect_uri" => config[:config][:redirect_uri],
        "access_type" => config[:config][:access_type] || "online",
        "response_type" => "code"
      }
      set_params(config)

      URI.encode_www_form(params)
    end

    # Set the parameters for the query
    def set_params(config)
      params["provider"] = config[:provider] if config[:provider]
      set_config_params(config)
      set_more_config(config)
    end

    # Set login related configurations
    def set_config_params(config)
      if config[:login_hint]
        params["login_hint"] = config[:login_hint]
        params["include_grant_scopes"] = config[:include_grant_scopes].to_s if config[:include_grant_scopes]
      end
      params["scope"] = config[:scope].join(" ") if config[:scope]
    end

    # More config
    def set_more_config(config)
      params["prompt"] = config[:prompt] if config[:prompt]
      params["metadata"] = config[:metadata] if config[:metadata]
      params["state"] = config[:state] if config[:state]
    end

    # Hashes the secret for PKCE authentication.
    #
    # @param secret [String] Randomly-generated authentication secret.
    # @return [Hash] Hashed authentication secret.
    def hash_pkce_secret(secret)
      Digest::SHA256.digest(secret).unpack1("H*")
      Base64.strict_encode64(Digest::SHA256.digest(secret))
    end

    # Sends the token request to the Nylas API.
    #
    # @param request [Hash] Code exchange request.
    def execute_token_request(request)
      execute(
        method: :post,
        path: "#{api_uri}/v3/connect/token",
        query: {},
        payload: request,
        headers: {},
        api_key: api_key,
        timeout: timeout
      )
    end
  end
end
