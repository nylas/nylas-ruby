# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Contact API
  class Contacts < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    # Return all contacts.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of contacts and API Request ID.
    def list(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts",
        query_params: query_params
      )
    end

    # Return a contact.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param contact_id [String] The id of the contact to return.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The contact and API request ID.
    def find(identifier:, contact_id:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}",
        query_params: query_params
      )
    end

    # Create a contact.
    #
    # @param identifier [String] Grant ID or email account in which to create the object.
    # @param request_body [Hash] The values to create the contact with.
    # @return [Array(Hash, String)] The created contact and API Request ID.
    def create(identifier:, request_body:)
      post(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts",
        request_body: request_body
      )
    end

    # Update a contact.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param contact_id [String] The id of the contact to update.
    # @param request_body [Hash] The values to update the contact with
    # @return [Array(Hash, String)] The updated contact and API Request ID.
    def update(identifier:, contact_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}",
        request_body: request_body
      )
    end

    # Delete a contact.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param contact_id [String] The id of the contact to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, contact_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}"
      )

      [true, request_id]
    end

    # Return all contact groups.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of contact groups and API Request ID.
    def list_groups(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/contacts/groups",
        query_params: query_params
      )
    end
  end
end
