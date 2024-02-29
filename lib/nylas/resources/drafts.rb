# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"
require_relative "../utils/file_utils"

module Nylas
  # Nylas Drafts API
  class Drafts < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all drafts.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String)] The list of drafts, API Request ID, and next cursor.
    def list(identifier:, query_params: nil)
      get_list(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts",
        query_params: query_params
      )
    end

    # Return an draft.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param draft_id [String] The id of the draft to return.
    # @return [Array(Hash, String)] The draft and API request ID.
    def find(identifier:, draft_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      )
    end

    # Create an draft.
    #
    # @param identifier [String] Grant ID or email account in which to create the draft.
    # @param request_body [Hash] The values to create the message with.
    #   If you're attaching files, you must pass an array of [File] objects, or
    #   you can use {FileUtils::attach_file_request_builder} to build each object attach.
    # @return [Array(Hash, String)] The created draft and API Request ID.
    def create(identifier:, request_body:)
      payload = request_body
      opened_files = []

      # Use form data only if the attachment size is greater than 3mb
      attachments = request_body[:attachments] || request_body["attachments"] || []
      attachment_size = attachments&.sum { |attachment| attachment[:size] || 0 } || 0

      if attachment_size >= FileUtils::FORM_DATA_ATTACHMENT_SIZE
        payload, opened_files = FileUtils.build_form_request(request_body)
      end

      response = post(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts",
        request_body: payload
      )

      opened_files.each(&:close)

      response
    end

    # Update an draft.
    #
    # @param identifier [String] Grant ID or email account in which to update the draft.
    # @param draft_id [String] The id of the draft to update.
    # @param request_body [Hash] The values to create the message with.
    #   If you're attaching files, you must pass an array of [File] objects, or
    #   you can use {FileUtils::attach_file_request_builder} to build each object attach.
    # @return [Array(Hash, String)] The updated draft and API Request ID.
    def update(identifier:, draft_id:, request_body:)
      payload = request_body
      opened_files = []

      # Use form data only if the attachment size is greater than 3mb
      attachments = request_body[:attachments] || request_body["attachments"] || []
      attachment_size = attachments&.sum { |attachment| attachment[:size] || 0 } || 0

      if attachment_size >= FileUtils::FORM_DATA_ATTACHMENT_SIZE
        payload, opened_files = FileUtils.build_form_request(request_body)
      end

      response = put(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}",
        request_body: payload
      )

      opened_files.each(&:close)

      response
    end

    # Delete an draft.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param draft_id [String] The id of the draft to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, draft_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      )

      [true, request_id]
    end

    # Send an draft.
    #
    # @param identifier [String] Grant ID or email account from which to send the draft.
    # @param draft_id [String] The id of the draft to send.
    # @return [Array(Hash, String)] The sent message draft and the API Request ID.
    def send(identifier:, draft_id:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      )
    end
  end
end
