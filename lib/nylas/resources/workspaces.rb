# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Workspaces API
  #
  # A workspace groups grants in a Nylas application by email domain. Grants can be
  # auto-grouped (by matching email domain) or manually assigned/removed.
  class Workspaces < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Patch
    include ApiOperations::Delete

    # Return all workspaces for the application.
    #
    # The list endpoint is not paginated; +data+ is a flat array of workspaces.
    #
    # @return [Array(Array(Hash), String, Hash)] The list of workspaces, API Request ID,
    #   and response headers.
    def list
      get(
        path: "#{api_uri}/v3/workspaces"
      )
    end

    # Return a workspace.
    #
    # @param workspace_id [String] The id of the workspace to return. Accepts a workspace
    #   UUID or an email domain.
    # @return [Array(Hash, String, Hash)] The workspace, API Request ID, and response headers.
    def find(workspace_id:)
      get(
        path: "#{api_uri}/v3/workspaces/#{workspace_id}"
      )
    end

    # Create a workspace.
    #
    # @param request_body [Hash] The values to create the workspace with. Only +name+ is
    #   required.
    # @return [Array(Hash, String, Hash)] The created workspace, API Request ID, and
    #   response headers.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/workspaces",
        request_body: request_body
      )
    end

    # Update a workspace.
    #
    # The API exposes update via PATCH only (there is no PUT route). The workspace must be
    # addressed by its UUID; a domain path param is not accepted on update.
    #
    # @param workspace_id [String] The UUID of the workspace to update.
    # @param request_body [Hash] The values to update the workspace with.
    # @return [Array(Hash, String)] The updated workspace and API Request ID.
    def update(workspace_id:, request_body:)
      patch(
        path: "#{api_uri}/v3/workspaces/#{workspace_id}",
        request_body: request_body
      )
    end

    # Delete a workspace.
    #
    # @param workspace_id [String] The id of the workspace to delete. Accepts a workspace
    #   UUID or an email domain.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(workspace_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/workspaces/#{workspace_id}"
      )

      [true, request_id]
    end

    # Auto-group grants into workspaces by matching email domain.
    #
    # Runs as a background job and returns immediately with a job ID. Rate limited to one
    # call per minute per application.
    #
    # @param request_body [Hash] Optional filters to scope which grants are grouped.
    # @return [Array(Hash, String, Hash)] The job info, API Request ID, and response headers.
    def auto_group(request_body: nil)
      post(
        path: "#{api_uri}/v3/workspaces/auto-group",
        request_body: request_body
      )
    end

    # Manually assign grants to or remove grants from a workspace.
    #
    # @param workspace_id [String] The id of the workspace to update. Accepts a workspace
    #   UUID or an email domain.
    # @param request_body [Hash] The grants to assign and/or remove (+assign_grants+,
    #   +remove_grants+).
    # @return [Array(Hash, String, Hash)] The assignment result, API Request ID, and
    #   response headers.
    def manual_assign(workspace_id:, request_body:)
      post(
        path: "#{api_uri}/v3/workspaces/#{workspace_id}/manual-assign",
        request_body: request_body
      )
    end
  end
end
