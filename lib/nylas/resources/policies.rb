# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Policies API (beta)
  #
  # Policies define message limits, spam-detection settings, options, and linked
  # rules for Nylas Agent Accounts. `application_id` and `organization_id` are
  # derived from the API key / gateway headers and are read-only.
  #
  # Policy objects (the Hash returned/accepted by these methods) carry these keys:
  # - +id+ [String] Policy UUID. Read-only; server-assigned on create.
  # - +name+ [String] 1-256 chars. Required on create.
  # - +application_id+ [String] Read-only; derived from the API key.
  # - +organization_id+ [String] Read-only; derived from the API key.
  # - +rules+ [Array<String>] Linked rule IDs.
  # - +created_at+ [Integer] Unix timestamp (seconds). Read-only.
  # - +updated_at+ [Integer] Unix timestamp (seconds). Read-only.
  # - +limits+ [Hash] Per-policy limits. Returned as *effective* values resolved
  #   against the org's billing plan, which may differ from what was sent. Keys:
  #   - +limit_attachment_size_limit+ [Integer] Bytes; >= 0, <= plan max.
  #   - +limit_attachment_count_limit+ [Integer] >= 0, <= plan max.
  #   - +limit_attachment_allowed_types+ [Array<String>] MIME types from the plan allow-list.
  #   - +limit_size_total_mime+ [Integer] Bytes; >= 0, <= plan max.
  #   - +limit_storage_total+ [Integer] Bytes. Unlimited-capable: -1 = unlimited.
  #   - +limit_count_daily_message_received+ [Integer] Per-grant daily received-message
  #     cap. Unlimited-capable: -1 = unlimited.
  #   - +limit_count_daily_email_sent+ [Integer] Per-grant daily sent-email cap.
  #     Unlimited-capable: -1 = unlimited.
  #   - +limit_inbox_retention_period+ [Integer] Days. Unlimited-capable: -1. Must be
  #     greater than spam retention when both set.
  #   - +limit_spam_retention_period+ [Integer] Days. Unlimited-capable: -1. Must be
  #     shorter than inbox retention when both set.
  # - +options+ [Hash] Policy options. Keys:
  #   - +additional_folders+ [Array<String>] Only allowed when the plan permits.
  #   - +use_cidr_aliasing+ [Boolean] Only allowed when the plan permits.
  # - +spam_detection+ [Hash] Spam-detection settings. Keys:
  #   - +use_list_dnsbl+ [Boolean] Always present in responses (false when unset).
  #   - +use_header_anomaly_detection+ [Boolean] Always present in responses (false when unset).
  #   - +spam_sensitivity+ [Float] 0.1-5.0 inclusive. Default 1.0.
  #
  # The unlimited sentinel for unlimited-capable fields is -1 only; values < -1 are
  # rejected, and -1 is honored only when the plan permits unlimited for that field.
  class Policies < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all policies.
    #
    # The list envelope is flat: the data array is the policies themselves and
    # +next_cursor+ is a top-level sibling. +next_cursor+ is present on every
    # non-empty page (including the last) and is not a has-more flag; page until
    # an empty data array is returned.
    #
    # @param query_params [Hash, nil] Query params to pass to the request
    #   (e.g. +limit+ — default 10, no server max; +page_token+ — opaque cursor).
    # @return [Array(Array(Hash), String, String, Hash)] The list of policies,
    #   API Request ID, next cursor, and response headers.
    def list(query_params: nil)
      get_list(
        path: "#{api_uri}/v3/policies",
        query_params: query_params
      )
    end

    # Return a policy.
    #
    # @param policy_id [String] The id of the policy to return.
    # @return [Array(Hash, String, Hash)] The policy, API request ID, and response headers.
    def find(policy_id:)
      get(
        path: "#{api_uri}/v3/policies/#{policy_id}"
      )
    end

    # Create a policy.
    #
    # @param request_body [Hash] The values to create the policy with. Honored keys:
    #   +name+ (required), +options+, +limits+, +rules+, +spam_detection+. Any
    #   +id+/+created_at+/+updated_at+/+application_id+/+organization_id+ are ignored.
    #   Omitted +limits+/+options+/+spam_detection+ sub-fields fall back to plan defaults.
    # @return [Array(Hash, String, Hash)] The created policy, API Request ID, and response headers.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/policies",
        request_body: request_body
      )
    end

    # Update a policy.
    #
    # The route verb is PUT, but the update is a partial nested merge: provided
    # sub-objects (+limits+/+options+/+spam_detection+) are merged field-by-field
    # onto the stored policy. Send only the fields you intend to change.
    #
    # @param policy_id [String] The id of the policy to update.
    # @param request_body [Hash] The values to update the policy with. Honored keys:
    #   +name+, +options+, +limits+, +rules+, +spam_detection+. Any
    #   +id+/+created_at+/+updated_at+/+application_id+/+organization_id+ are ignored.
    # @return [Array(Hash, String)] The updated policy and API Request ID.
    def update(policy_id:, request_body:)
      put(
        path: "#{api_uri}/v3/policies/#{policy_id}",
        request_body: request_body
      )
    end

    # Delete a policy.
    #
    # @param policy_id [String] The id of the policy to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(policy_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/policies/#{policy_id}"
      )

      [true, request_id]
    end
  end
end
