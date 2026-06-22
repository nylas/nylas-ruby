# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Module representing the possible 'trigger' values for a Rule.
  module RuleTrigger
    INBOUND = "inbound"
    OUTBOUND = "outbound"
  end

  # Module representing the possible 'match.operator' values for a Rule.
  module RuleMatchOperator
    ANY = "any"
    ALL = "all"
  end

  # Module representing the possible condition 'field' values for a Rule.
  module RuleConditionField
    FROM_ADDRESS = "from.address"
    FROM_DOMAIN = "from.domain"
    FROM_TLD = "from.tld"
    RECIPIENT_ADDRESS = "recipient.address"
    RECIPIENT_DOMAIN = "recipient.domain"
    RECIPIENT_TLD = "recipient.tld"
    OUTBOUND_TYPE = "outbound.type"
  end

  # Module representing the possible condition 'operator' values for a Rule.
  module RuleConditionOperator
    IS = "is"
    IS_NOT = "is_not"
    CONTAINS = "contains"
    IN_LIST = "in_list"
  end

  # Module representing the possible 'outbound.type' condition values for a Rule.
  module RuleOutboundType
    COMPOSE = "compose"
    REPLY = "reply"
  end

  # Module representing the possible action 'type' values for a Rule.
  module RuleActionType
    BLOCK = "block"
    MARK_AS_SPAM = "mark_as_spam"
    ASSIGN_TO_FOLDER = "assign_to_folder"
    MARK_AS_READ = "mark_as_read"
    MARK_AS_STARRED = "mark_as_starred"
    ARCHIVE = "archive"
    TRASH = "trash"
  end

  # Module representing the possible 'evaluation_stage' values in a rule evaluation.
  module RuleEvaluationStage
    SMTP_RCPT = "smtp_rcpt"
    INBOX_PROCESSING = "inbox_processing"
    OUTBOUND_SEND = "outbound_send"
  end

  # Nylas Rules API
  class Rules < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all rules.
    #
    # The list endpoint returns a nested envelope
    # ({ request_id, data: { items: [...], next_cursor } }), so the items and
    # cursor are unwrapped here defensively rather than via the standard
    # get_list helper, which would mis-read the nested shape.
    #
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String, Hash)]
    #   The list of rules, API Request ID, next cursor, and response headers.
    def list(query_params: nil)
      response = get_raw(
        path: "#{api_uri}/v3/rules",
        query_params: query_params
      )

      data = response[:data]
      # Unwrap only when the envelope actually carries an :items key. Go's
      # ListWithCursorResult serializes a nil slice as "items": null, so coerce
      # that to [] rather than falling back to the envelope hash itself.
      items = if data.is_a?(Hash) && data.key?(:items)
                data[:items] || []
              else
                data
              end
      next_cursor = data.is_a?(Hash) ? data[:next_cursor] : response[:next_cursor]

      [items, response[:request_id], next_cursor, response[:headers]]
    end

    # Return a rule.
    #
    # @param rule_id [String] The id of the rule to return.
    # @return [Array(Hash, String, Hash)] The rule, API request ID, and response headers.
    def find(rule_id:)
      get(
        path: "#{api_uri}/v3/rules/#{rule_id}"
      )
    end

    # Create a rule.
    #
    # @param request_body [Hash] The values to create the rule with.
    # @return [Array(Hash, String)] The created rule and API Request ID.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/rules",
        request_body: request_body
      )
    end

    # Update a rule. Only the provided fields are changed (partial update).
    #
    # @param rule_id [String] The id of the rule to update.
    # @param request_body [Hash] The values to update the rule with.
    # @return [Array(Hash, String)] The updated rule and API Request ID.
    def update(rule_id:, request_body:)
      put(
        path: "#{api_uri}/v3/rules/#{rule_id}",
        request_body: request_body
      )
    end

    # Delete a rule.
    #
    # @param rule_id [String] The id of the rule to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(rule_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/rules/#{rule_id}"
      )

      [true, request_id]
    end

    # Return all rule evaluations for a grant.
    #
    # This endpoint returns a flat array with no cursor, so the standard
    # get_list helper is used (next_cursor is always nil).
    #
    # @param grant_id [String] The id of the grant to query rule evaluations for.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String, Hash)]
    #   The list of rule evaluations, API Request ID, next cursor (always nil
    #   for this endpoint), and response headers.
    def list_evaluations(grant_id:, query_params: nil)
      get_list(
        path: "#{api_uri}/v3/grants/#{grant_id}/rule-evaluations",
        query_params: query_params
      )
    end
  end
end
