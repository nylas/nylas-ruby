# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Attachment API
  class Attachments < Resource
    include ApiOperations::Get

    # Return metadata of an attachment.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param attachment_id [String] The id of the attachment to retrieve.
    # @param query_params [Hash] The query parameters to include in the request.
    # @return [Array(Hash, String)] The attachment and API request ID.
    def find(identifier:, attachment_id:, query_params:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}",
        query_params: query_params
      )
    end

    # Download the attachment data.
    #
    # This method supports streaming the download by passing a block, which will
    # be called with each chunk of the response body as it is read. If no block
    # is given, the entire response will be read into memory and returned (not recommended
    # for large files).
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param attachment_id [String] The ID of the attachment to be downloaded.
    # @param query_params [Hash] The query parameters to include in the request.
    # @yieldparam chunk [String] A chunk of the response body.
    # @return [nil, String] Returns nil when a block is given (streaming mode).
    #   When no block is provided, the return is the entire raw response body.
    def download(identifier:, attachment_id:, query_params:, &block)
      download_request(
        path: "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}/download",
        query: query_params,
        api_key: api_key,
        timeout: timeout,
        &block
      )
    end

    # Download the attachment as a byte array.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param attachment_id [String] The ID of the attachment to be downloaded.
    # @param query_params [Hash] The query parameters to include in the request.
    # @return [nil, Array(Integer)] Returns nil when a block is given (streaming mode).
    #   When no block is provided, the return is the entire raw response body.
    def download_bytes(identifier:, attachment_id:, query_params:)
      data = download_request(
        path: "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}/download",
        query: query_params,
        api_key: api_key,
        timeout: timeout
      )

      data&.bytes
    end
  end
end
