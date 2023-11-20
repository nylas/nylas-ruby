# frozen_string_literal: true

require_relative "resource"
require_relative "smart_compose"
require_relative "../handler/api_operations"
require_relative "../utils/file_utils"

module Nylas
  # Nylas Messages API
  class Messages < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete

    attr_reader :smart_compose

    # Initializes the messages resource.
    # @param sdk_instance [Nylas::API] The API instance to which the resource is bound.
    def initialize(sdk_instance)
      super(sdk_instance)
      @smart_compose = SmartCompose.new(sdk_instance)
    end

    # Return all messages.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Array(Hash), String)] The list of messages and API Request ID.
    def list(identifier:, query_params: nil)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages",
        query_params: query_params
      )
    end

    # Return a message.
    #
    # @param identifier [String] Grant ID or email account to query.
    # @param message_id [String] The id of the message to return.
    # @return [Array(Hash, String)] The message and API request ID.
    def find(identifier:, message_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      )
    end

    # Update a message.
    #
    # @param identifier [String] Grant ID or email account in which to update an object.
    # @param message_id [String] The id of the message to update.
    # @param request_body [Hash] The values to update the message with
    # @return [Array(Hash, String)] The updated message and API Request ID.
    def update(identifier:, message_id:, request_body:)
      put(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}",
        request_body: request_body
      )
    end

    # Delete a message.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param message_id [String] The id of the message to delete.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(identifier:, message_id:)
      _, request_id = delete(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      )

      [true, request_id]
    end

    # Send a message.
    #
    # @param identifier [String] Grant ID or email account from which to delete an object.
    # @param request_body [Hash] The values to create the message with.
    #   If you're attaching files, you must pass an array of [File] objects, or
    #   you can use {FileUtils::attach_file_request_builder} to build each object attach.
    # @return [Array(Hash, String)] The sent message and the API Request ID.
    def send(identifier:, request_body:)
      form_body, opened_files = FileUtils.build_form_request(request_body)

      response = post(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/send",
        request_body: form_body
      )

      opened_files.each(&:close)

      response
    end

    # Retrieve your scheduled messages.
    #
    # @param identifier [String] Grant ID or email account from which to find the scheduled message from.
    # @param schedule_id [String] The id of the scheduled message to stop.
    # @return [Array(Hash, String)] The list of scheduled messages and the API Request ID.
    def list_scheduled_messages(identifier:, schedule_id:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/schedules/#{schedule_id}"
      )
    end

    # Retrieve your scheduled messages.
    #
    # @param identifier [String] Grant ID or email account from which to list the scheduled messages from.
    # @return [Array(Hash, String)] The scheduled message and the API Request ID.
    def find_scheduled_messages(identifier:)
      get(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/schedules"
      )
    end

    # Stop a scheduled message.
    #
    # @param identifier [String] Grant ID or email account from which to list the scheduled messages from.
    # @param schedule_id [String] The id of the scheduled message to stop..
    # @return [Array(Hash, String)] The scheduled message and the API Request ID.
    def stop_scheduled_messages(identifier:, schedule_id:)
      delete(
        path: "#{api_uri}/v3/grants/#{identifier}/messages/schedules/#{schedule_id}"
      )
    end
  end
end
