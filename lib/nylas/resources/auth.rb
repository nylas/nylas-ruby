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

    # Create a Grant via Custom Authentication.
    #
    # @param request_body [Hash] The values to create the Grant with.
    # @return [Array(Hash, String)] Created grant and API Request ID.
    def custom_authentication(request_body)
      post(
        path: "#{api_uri}/v3/connect/custom",
        request_body: request_body
      )
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
    # @return [Hash] URL for hosted authentication with the secret and the hashed secret.
    def url_for_oauth2_pkce(config)
      url = url_auth_builder(config)

      # Generates a secret and hashes it.
      secret = SecureRandom.uuid
      secret_hash = hash_pkce_secret(secret)

      # Adds code challenge to URL generation.
      url.query = build_query_with_pkce(config, secret_hash)

      # Returns the URL with secret and hashed secret.
      { secret: secret, secret_hash: secret_hash, url: url.to_s }
    end

    # Builds the URL for admin consent authentication for Microsoft.
    #
    # @param config [Hash] Configuration for the authentication request.
    # @return [String] URL for hosted authentication.
    def url_for_admin_consent(config)
      config_with_provider = config.merge("provider" => "microsoft")
      url = url_auth_builder(config_with_provider)
      url.query = build_query_with_admin_consent(config)

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
    # @return [String] Updated list of parameters, including those specific to admin
    # consent.
    def build_query_with_admin_consent(config)
      params = build_query(config)

      # Appends new params specific for admin consent.
      params[:provider] = "microsoft"
      params[:response_type] = "adminconsent"
      params[:credential_id] = config[:credential_id] if config[:credential_id]

      URI.encode_www_form(params).gsub("+", "%20")
    end

    # Builds the query with PKCE.
    #
    # @param config [Hash] Configuration for the query.
    # @param secret_hash [Hash] Hashed secret.
    # @return [String] Updated list of encoded parameters, including those specific
    # to PKCE.
    def build_query_with_pkce(config, secret_hash)
      params = build_query(config)

      # Appends new PKCE specific params.
      params[:code_challenge_method] = "s256"
      params[:code_challenge] = secret_hash

      URI.encode_www_form(params).gsub("+", "%20")
    end

    # Builds the authentication URL.
    #
    # @param config [Hash] Configuration for the query.
    # @return [URI] List of components for the authentication URL.
    def url_auth_builder(config)
      builder = URI.parse(api_uri)
      builder.path = "/v3/connect/auth"
      builder.query = URI.encode_www_form(build_query(config)).gsub!("+", "%20")

      builder
    end

    # Builds the query.
    #
    # @param config [Hash] Configuration for the query.
    # @return [Hash] List of parameters to encode in the query.
    def build_query(config)
      params = {
        client_id: config[:client_id],
        redirect_uri: config[:redirect_uri],
        access_type: config[:access_type] || "online",
        response_type: "code"
      }
      params[:provider] = config[:provider] if config[:provider]
      params[:prompt] = config[:prompt] if config[:prompt]
      params[:metadata] = config[:metadata] if config[:metadata]
      params[:state] = config[:state] if config[:state]
      params[:scope] = config[:scope].join(" ") if config[:scope]
      if config[:login_hint]
        params[:login_hint] = config[:login_hint]
        params[:include_grant_scopes] = config[:include_grant_scopes].to_s if config[:include_grant_scopes]
      end

      params
    end

    # Hash a plain text secret for use in PKCE.
    #
    # @param secret [String] The plain text secret to hash.
    # @return [String] The hashed secret with base64 encoding (without padding).
    def hash_pkce_secret(secret)
      sha256_hash = Digest::SHA256.hexdigest(secret)
      Base64.urlsafe_encode64(sha256_hash, padding: false)
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
