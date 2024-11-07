# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Scheduler Configurations API
  class Configurations < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all Scheduler Configurations.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String)] The list of configurations, API Request ID,
    # and next cursor.
    def list(identifier:, query_params: nil)
      get_list(
        path: "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations",
        query_params: query_params
      )
    end

    # Return a Configuration.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param configuration_id [String] The id of the configuration to return.
    # @return [Array(Hash, String)] The configuration and API request ID.
    def find(identifier:, configuration_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}"
      )
    end

    # Create a configuration.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the configuration with.
    # @return [Array(Hash, String)] The created configuration and API Request ID.
    def create(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations",
        request_body: request_body
      )
    end

    # Update a configuration.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param configuration_id [String] The id of the configuration to update.
    # @param request_body [Hash] The values to update the configuration with
    # @return [Array(Hash, String)] The updated configuration and API Request ID.
    def update(identifier:, configuration_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}",
        request_body: request_body
      )
    end

    # Delete a configuration.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param configuration_id [String] The id of the configuration to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, configuration_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}"
      )

      [true, request_id]
    end
  end
end
