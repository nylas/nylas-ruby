# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Notetaker API
  class Notetakers < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete
    include ApiOperations::Patch

    # Return all notetakers.
    #
    # @param identifier [String, nil] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String, String)] The list of notetakers, API Request ID, and next cursor.
    def list(identifier: nil, query_params: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers" : "#{api_uri}/v3/notetakers"

      get_list(
        path: path,
        query_params: query_params
      )
    end

    # Return a notetaker.
    #
    # @param notetaker_id [String] The id of the notetaker to return.
    # @param identifier [String, nil] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The notetaker and API request ID.
    def find(notetaker_id:, identifier: nil, query_params: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}" : "#{api_uri}/v3/notetakers/#{notetaker_id}"

      get(
        path: path,
        query_params: query_params
      )
    end

    # Invite a notetaker to a meeting.
    #
    # @param request_body [Hash] The values to create the notetaker with.
    # @param identifier [String, nil] Grant ID or email account in which to create the object.
    # @return [Array(Hash, String)] The created notetaker and API Request ID.
    def create(request_body:, identifier: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers" : "#{api_uri}/v3/notetakers"

      post(
        path: path,
        request_body: request_body
      )
    end

    # Update a scheduled notetaker.
    #
    # @param notetaker_id [String] The id of the notetaker to update.
    # @param request_body [Hash] The values to update the notetaker with
    # @param identifier [String, nil] Grant ID or email account in which to update an object.
    # @return [Array(Hash, String)] The updated notetaker and API Request ID.
    def update(notetaker_id:, request_body:, identifier: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}" : "#{api_uri}/v3/notetakers/#{notetaker_id}"

      patch(
        path: path,
        request_body: request_body
      )
    end

    # Download notetaker media.
    #
    # @param notetaker_id [String] The id of the notetaker to download media from.
    # @param identifier [String, nil] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The media data and API request ID.
    def download_media(notetaker_id:, identifier: nil, query_params: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/media" : "#{api_uri}/v3/notetakers/#{notetaker_id}/media"

      get(
        path: path,
        query_params: query_params
      )
    end

    # Remove a notetaker from a meeting.
    #
    # @param notetaker_id [String] The id of the notetaker to remove.
    # @param identifier [String, nil] Grant ID or email account to query.
    # @return [Array(Hash, String)] The response data and API request ID.
    def leave(notetaker_id:, identifier: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/leave" : "#{api_uri}/v3/notetakers/#{notetaker_id}/leave"

      post(
        path: path,
        request_body: {}
      )
    end

    # Cancel a scheduled notetaker.
    #
    # @param notetaker_id [String] The id of the notetaker to cancel.
    # @param identifier [String, nil] Grant ID or email account from which to delete an object.
    # @return [Array(TrueClass, String)] True and the API Request ID for the cancel operation.
    def cancel(notetaker_id:, identifier: nil)
      path = identifier ? "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/cancel" : "#{api_uri}/v3/notetakers/#{notetaker_id}/cancel"

      _, request_id = delete(
        path: path
      )

      [true, request_id]
    end
  end
end
