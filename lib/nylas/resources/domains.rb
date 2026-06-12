# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Module representing the possible 'type' values in a domain verification attempt.
  # @see https://developer.nylas.com/docs/reference/api/manage-domains/
  module DomainVerificationType
    OWNERSHIP = "ownership"
    MX = "mx"
    SPF = "spf"
    DKIM = "dkim"
    FEEDBACK = "feedback"
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

    # Return all domains for the caller's organization.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    #   Supported keys: `domain` (filter by exact domain address), `region`, `limit`, `page_token`.
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Array(Hash), String, String, Hash)]
    #   The list of domains, API Request ID, next cursor, and response headers.
    def list(headers:, query_params: nil)
      validate_service_account_headers!(headers)

      get_list(
        path: "#{api_uri}/v3/admin/domains",
        query_params: query_params,
        headers: headers
      )
    end

    # Return a domain.
    #
    # @param domain_id [String] The identifier of the domain to return.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Hash, String, Hash)] The domain, API request ID, and response headers.
    def find(domain_id:, headers:)
      validate_service_account_headers!(headers)

      get(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}",
        headers: headers
      )
    end

    # Create a domain.
    #
    # @param request_body [Hash] The values to create the domain with.
    #   Requires `name` and `domain_address`.
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Hash, String, Hash)] The created domain, API Request ID, and response headers.
    def create(request_body:, headers:)
      validate_service_account_headers!(headers)

      post(
        path: "#{api_uri}/v3/admin/domains",
        request_body: request_body,
        headers: headers
      )
    end

    # Update a domain.
    #
    # @param domain_id [String] The identifier of the domain to update.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The values to update the domain with.
    #   The response echoes only the updated fields, not a full domain object.
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Hash, String)] The updated domain fields and API Request ID.
    def update(domain_id:, request_body:, headers:)
      validate_service_account_headers!(headers)

      put(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}",
        request_body: request_body,
        headers: headers
      )
    end

    # Delete a domain.
    #
    # @param domain_id [String] The identifier of the domain to delete.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(domain_id:, headers:)
      validate_service_account_headers!(headers)

      _, request_id = delete(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}",
        headers: headers
      )

      [true, request_id]
    end

    # Get the DNS record info for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def info(domain_id:, request_body:, headers:)
      validate_service_account_headers!(headers)

      post(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}/info",
        request_body: request_body,
        headers: headers
      )
    end

    # Trigger a DNS verification check for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @param headers [Hash] Nylas Service Account request signing headers.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def verify(domain_id:, request_body:, headers:)
      validate_service_account_headers!(headers)

      post(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}/verify",
        request_body: request_body,
        headers: headers
      )
    end

    private

    def validate_service_account_headers!(headers)
      header_values = headers || {}
      missing_headers = REQUIRED_SERVICE_ACCOUNT_HEADERS.reject do |header|
        header_values.key?(header) && !header_values[header].to_s.empty?
      end

      return if missing_headers.empty?

      raise ArgumentError,
            "Missing required service account authentication headers: #{missing_headers.join(', ')}"
    end
  end
end
