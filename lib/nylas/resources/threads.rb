# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Threads API
  class Threads < Resource
    include ApiOperations::Get
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all threads.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of threads and API Request ID.
    def list(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/threads",
        query_params: query_params
      )
    end

    # Return an thread.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param thread_id [String] The id of the thread to return.
    # @return [Array(Hash, String)] The thread and API request ID.
    def find(identifier:, thread_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      )
    end

    # Update an thread.
    #
    # @param identifier [String] Grant ID or email account in which to update the thread.
    # @param thread_id [String] The id of the thread to update.
    # @param request_body [Hash] The values to update the thread with
    # @return [Array(Hash, String)] The updated thread and API Request ID.
    def update(identifier:, thread_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}",
        request_body: request_body
      )
    end

    # Delete an thread.
    #
    # @param identifier [String] Grant ID or email account from which to delete the thread.
    # @param thread_id [String] The id of the thread to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, thread_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      )

      [true, request_id]
    end
  end
end
