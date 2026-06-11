# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Module representing the possible 'type' values in a domain verification attempt.
  # @see https://developer.nylas.com/docs/api/v3/admin/#tag--Manage-Domains
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
  class Domains < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all domains for the caller's organization.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    #   Supported keys: `domain` (filter by exact domain address), `region`, `limit`, `page_token`.
    # @return [Array(Array(Hash), String, String, Hash)]
    #   The list of domains, API Request ID, next cursor, and response headers.
    def list(query_params: nil)
      get_list(
        path: "#{api_uri}/v3/admin/domains",
        query_params: query_params
      )
    end

    # Return a domain.
    #
    # @param domain_id [String] The identifier of the domain to return.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @return [Array(Hash, String, Hash)] The domain, API request ID, and response headers.
    def find(domain_id:)
      get(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}"
      )
    end

    # Create a domain.
    #
    # @param request_body [Hash] The values to create the domain with.
    #   Requires `name` and `domain_address`.
    # @return [Array(Hash, String, Hash)] The created domain, API Request ID, and response headers.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/admin/domains",
        request_body: request_body
      )
    end

    # Update a domain.
    #
    # @param domain_id [String] The identifier of the domain to update.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The values to update the domain with.
    #   The response echoes only the updated fields, not a full domain object.
    # @return [Array(Hash, String)] The updated domain fields and API Request ID.
    def update(domain_id:, request_body:)
      put(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}",
        request_body: request_body
      )
    end

    # Delete a domain.
    #
    # @param domain_id [String] The identifier of the domain to delete.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(domain_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}"
      )

      [true, request_id]
    end

    # Get the DNS record info for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def info(domain_id:, request_body:)
      post(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}/info",
        request_body: request_body
      )
    end

    # Trigger a DNS verification check for a domain verification type.
    #
    # @param domain_id [String] The identifier of the domain.
    #   Accepts either a UUID or a domain address (FQDN/email format).
    # @param request_body [Hash] The verification attempt values. Requires `type`.
    # @return [Array(Hash, String, Hash)]
    #   The domain verification result, API Request ID, and response headers.
    def verify(domain_id:, request_body:)
      post(
        path: "#{api_uri}/v3/admin/domains/#{domain_id}/verify",
        request_body: request_body
      )
    end
  end
end
