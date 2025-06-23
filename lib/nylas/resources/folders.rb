# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Folder API
  class Folders < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all folders.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    #   Supported parameters include:
    #   - single_level: (Boolean) For Microsoft accounts only. If true, retrieves folders from
    #     a single-level hierarchy only. If false (default), retrieves folders across a
    #     multi-level hierarchy.
    #   - include_hidden_folders [Boolean] (Microsoft only) When true, includes hidden folders.
    # @return [Array(Array(Hash), String, String)] The list of folders, API Request ID, and next cursor.
    def list(identifier:, query_params: nil)
      get_list(
        path: "#{api_uri}/v3/grants/#{identifier}/folders",
        query_params: query_params
      )
    end

    # Return a folder.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param folder_id [String] The id of the folder to return.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The folder and API request ID.
    def find(identifier:, folder_id:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}",
        query_params: query_params
      )
    end

    # Create a folder.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the folder with.
    # @return [Array(Hash, String)] The created folder and API Request ID.
    def create(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/folders",
        request_body: request_body
      )
    end

    # Update a folder.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param folder_id [String] The id of the folder to update.
    # @param request_body [Hash] The values to update the folder with
    # @return [Array(Hash, String)] The updated folder and API Request ID.
    def update(identifier:, folder_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}",
        request_body: request_body
      )
    end

    # Delete a folder.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param folder_id [String] The id of the folder to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, folder_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      )

      [true, request_id]
    end
  end
end
