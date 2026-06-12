# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"
require_relative "../handler/service_account_signer"
require "uri"

module Nylas
  # Module representing the possible 'type' values in a domain verification request.
  # @see https://developer.nylas.com/docs/reference/api/manage-domains/
  module DomainVerificationRequestType
    OWNERSHIP = "ownership"
    MX = "mx"
    SPF = "spf"
    DKIM = "dkim"
    FEEDBACK = "feedback"
  end

  # Module representing the possible 'type' values in a domain verification result.
  # @see https://developer.nylas.com/docs/reference/api/manage-domains/
  module DomainVerificationType
    OWNERSHIP = DomainVerificationRequestType::OWNERSHIP
    MX = DomainVerificationRequestType::MX
    SPF = DomainVerificationRequestType::SPF
    DKIM = DomainVerificationRequestType::DKIM
    FEEDBACK = DomainVerificationRequestType::FEEDBACK
    DMARC = "dmarc"
    ARC = "arc"
  end

  # Module representing the possible 'status' values in a domain verification result.
  module DomainVerificationStatus
    PENDING = "pending"
    DONE = "done"
    FAILED = "failed"
  end

  # Nylas Manage Domains API
  #
  # These endpoints require Nylas Service Account request signing. Pass headers
  # containing `X-Nylas-Kid`, `X-Nylas-Timestamp`, `X-Nylas-Nonce`, and
  # `X-Nylas-Signature` generated for the exact request being sent.
  class Domains < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    REQUIRED_SERVICE_ACCOUNT_HEADERS = %w[
      X-Nylas-Kid
      X-Nylas-Timestamp
      X-Nylas-Nonce
      X-Nylas-Signature
    ].freeze
    DOMAINS_PATH = "/v3/admin/domains"

    # Return all domains for the caller's organization.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    #   Supported keys: `domain` (filter by exact domain address), `region`, `limit`, `page_token`.
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Array(Hash), String, String, Hash)]
    #   The list of domains, API Request ID, next cursor, and response headers.
    def list(headers: nil, query_params: nil, signer: nil)
      request_headers, = signed_request_headers(method: :get, relative_path: DOMAINS_PATH,
                                                headers: headers, signer: signer)

      get_list(
        path: full_path(DOMAINS_PATH),
        query_params: query_params,
        headers: request_headers
      )
    end

    # Return a domain.
    #
    # @param domain_id [String] The identifier of the domain to return.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Hash, String, Hash)] The domain, API request ID, and response headers.
    def find(domain_id:, headers: nil, signer: nil)
      relative_path = "#{DOMAINS_PATH}/#{encoded_domain_id(domain_id)}"
      request_headers, = signed_request_headers(method: :get, relative_path: relative_path,
                                                headers: headers, signer: signer)

      get(
        path: full_path(relative_path),
        headers: request_headers
      )
    end

    # Create a domain.
    #
    # @param request_body [Hash] The values to create the domain with.
    #   Requires `name` and `domain_address`.
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Hash, String, Hash)] The created domain, API Request ID, and response headers.
    def create(request_body:, headers: nil, signer: nil)
      request_headers, serialized_body = signed_request_headers(
        method: :post,
        relative_path: DOMAINS_PATH,
        body: request_body,
        headers: headers,
        signer: signer
      )

      request = {
        path: full_path(DOMAINS_PATH),
        request_body: serialized_body.nil? ? request_body : nil,
        headers: request_headers
      }
      request[:serialized_json_body] = serialized_body unless serialized_body.nil?
      post(**request)
    end

    # Update a domain.
    #
    # @param domain_id [String] The identifier of the domain to update.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The values to update the domain with.
    #   The response echoes only the updated fields, not a full domain object.
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Hash, String)] The updated domain fields and API Request ID.
    def update(domain_id:, request_body:, headers: nil, signer: nil)
      relative_path = "#{DOMAINS_PATH}/#{encoded_domain_id(domain_id)}"
      request_headers, serialized_body = signed_request_headers(
        method: :put,
        relative_path: relative_path,
        body: request_body,
        headers: headers,
        signer: signer
      )

      request = {
        path: full_path(relative_path),
        request_body: serialized_body.nil? ? request_body : nil,
        headers: request_headers
      }
      request[:serialized_json_body] = serialized_body unless serialized_body.nil?
      put(**request)
    end

    # Delete a domain.
    #
    # @param domain_id [String] The identifier of the domain to delete.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(domain_id:, headers: nil, signer: nil)
      relative_path = "#{DOMAINS_PATH}/#{encoded_domain_id(domain_id)}"
      request_headers, = signed_request_headers(method: :delete, relative_path: relative_path,
                                                headers: headers, signer: signer)

      _, request_id = delete(
        path: full_path(relative_path),
        headers: request_headers
      )

      [true, request_id]
    end

    # Get the DNS record info for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def info(domain_id:, request_body:, headers: nil, signer: nil)
      relative_path = "#{DOMAINS_PATH}/#{encoded_domain_id(domain_id)}/info"
      request_headers, serialized_body = signed_request_headers(
        method: :post,
        relative_path: relative_path,
        body: request_body,
        headers: headers,
        signer: signer
      )

      request = {
        path: full_path(relative_path),
        request_body: serialized_body.nil? ? request_body : nil,
        headers: request_headers
      }
      request[:serialized_json_body] = serialized_body unless serialized_body.nil?
      post(**request)
    end

    # Trigger a DNS verification check for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @param headers [Hash, nil] Nylas Service Account request signing headers.
    # @param signer [ServiceAccountSigner, nil] Signer to generate Nylas Service Account headers.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def verify(domain_id:, request_body:, headers: nil, signer: nil)
      relative_path = "#{DOMAINS_PATH}/#{encoded_domain_id(domain_id)}/verify"
      request_headers, serialized_body = signed_request_headers(
        method: :post,
        relative_path: relative_path,
        body: request_body,
        headers: headers,
        signer: signer
      )

      request = {
        path: full_path(relative_path),
        request_body: serialized_body.nil? ? request_body : nil,
        headers: request_headers
      }
      request[:serialized_json_body] = serialized_body unless serialized_body.nil?
      post(**request)
    end

    private

    # Manage Domains uses Nylas Service Account signing headers instead of API-key bearer auth.
    def api_key
      nil
    end

    def full_path(relative_path)
      "#{api_uri}#{relative_path}"
    end

    def encoded_domain_id(domain_id)
      URI.encode_www_form_component(domain_id)
    end

    def signed_request_headers(method:, relative_path:, headers:, signer:, body: nil)
      request_headers = headers.nil? ? {} : headers.dup
      serialized_body = body.nil? ? nil : Nylas::ServiceAccountSigner.canonical_json(body)
      if signer
        signer_headers, serialized_body = signer.build_headers(
          method: method,
          path: relative_path,
          body: body
        )
        request_headers.merge!(signer_headers)
      end

      validate_service_account_headers!(request_headers)
      [request_headers, serialized_body]
    end

    def validate_service_account_headers!(headers)
      header_values = headers || {}
      normalized_headers = header_values.transform_keys do |key|
        key.to_s.downcase
      end
      missing_headers = REQUIRED_SERVICE_ACCOUNT_HEADERS.select do |header|
        normalized_headers[header.downcase].to_s.empty?
      end

      return if missing_headers.empty?

      raise ArgumentError,
            "Missing required service account authentication headers: #{missing_headers.join(', ')}"
    end
  end
end
