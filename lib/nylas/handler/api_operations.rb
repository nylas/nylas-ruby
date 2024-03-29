# frozen_string_literal: true

require_relative "http_client"

module Nylas
  # Allows resources to perform API operations on the Nylas API endpoints without exposing the HTTP
  # client to the end user.
  module ApiOperations
    # Performs a GET call to the Nylas API.
    module Get
      protected

      include HttpClient
      # Performs a GET call to the Nylas API for a single item response.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @return [Array([Hash, Array], String)] Nylas data object and API Request ID.
      def get(path:, query_params: {})
        response = get_raw(path: path, query_params: query_params)

        [response[:data], response[:request_id]]
      end

      # Performs a GET call to the Nylas API for a list response.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @return [Array(Array(Hash), String, String)] Nylas data array, API Request ID, and next cursor.
      def get_list(path:, query_params: {})
        response = get_raw(path: path, query_params: query_params)

        [response[:data], response[:request_id], response[:next_cursor]]
      end

      private

      # Performs a GET call to the Nylas API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @return [Hash] The JSON response from the Nylas API.
      def get_raw(path:, query_params: {})
        execute(
          method: :get,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )
      end
    end

    # Performs a POST call to the Nylas API.
    module Post
      protected

      include HttpClient
      # Performs a POST call to the Nylas API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return Nylas data object and API Request ID.
      def post(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a PUT call to the Nylas API.
    module Put
      protected

      include HttpClient
      # Performs a PUT call to the Nylas API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return Nylas data object and API Request ID.
      def put(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :put,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a PATCH call to the Nylas API.
    module Patch
      protected

      include HttpClient
      # Performs a PATCH call to the Nylas API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param request_body [Hash, nil] Request body to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return Nylas data object and API Request ID.
      def patch(path:, query_params: {}, request_body: nil, headers: {})
        response = execute(
          method: :patch,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end

    # Performs a DELETE call to the Nylas API.
    module Delete
      protected

      include HttpClient
      # Performs a DELETE call to the Nylas API.
      #
      # @param path [String] Destination path for the call.
      # @param query_params [Hash, {}] Query params to pass to the call.
      # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
      # @return Nylas data object and API Request ID.
      def delete(path:, query_params: {}, headers: {})
        response = execute(
          method: :delete,
          path: path,
          query: query_params,
          headers: headers,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        )

        [response[:data], response[:request_id]]
      end
    end
  end
end
