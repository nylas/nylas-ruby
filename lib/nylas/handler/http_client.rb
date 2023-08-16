# frozen_string_literal: true

require "rest-client"

require_relative "../errors"
require_relative "../version"

module Nylas
  require "yajl"
  require "base64"

  # Plain HTTP client that can be used to interact with the Nylas API without any type casting.
  module HttpClient
    protected

    attr_accessor :api_server
    attr_writer :default_headers

    # Sends a request to the Nylas API. Returns a successful response if the request succeeds, or a
    # failed response if the request encounters a JSON parse error.
    #
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch.
    # @param path [String, nil] Relative path from the API Base. This is the preferred way to execute
    # arbitrary or-not-yet-SDK-ified API commands.
    # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
    # @param query [Hash, {}] Hash of names and values to include in the query section of the URI
    # fragment.
    # @param payload [String, Hash, nil] Body to send with the request.
    # @param api_key [Hash, nil] API key to send with the request.
    # @param timeout [Hash, nil] Timeout value to send with the request.
    # @return [Object] Parsed JSON response from the API.
    def execute(method:, path: nil, headers: {}, query: {}, payload: nil, api_key: nil, timeout: nil)
      request = build_request(method: method, path: path, headers: headers,
                              query: query, payload: payload, api_key: api_key, timeout: timeout)
      rest_client_execute(**request) do |response, _request, result|
        content_type = nil

        if response.headers && response.headers[:content_type]
          content_type = response.headers[:content_type].downcase
        end

        begin
          response = parse_response(response) if content_type == "application/json"
        rescue Nylas::JsonParseError
          handle_failed_response(result, response, path)
          raise
        end

        handle_failed_response(result, response, path)
        return response
      end
    end

    # Builds a request sent to the Nylas API.
    #
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch.
    # @param path [String, nil] Relative path from the API Base.
    # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
    # @param query [Hash, {}] Hash of names and values to include in the query section of the URI
    # fragment.
    # @param payload [String, Hash, nil] Body to send with the request.
    # @param timeout [Hash, nil] Timeout value to send with the request.
    # @param api_key [Hash, nil] API key to send with the request.
    # @return [Object] The request information after processing. This includes an updated payload
    # and headers.
    def build_request(
      method:, path: nil, headers: {}, query: {}, payload: nil, timeout: nil, api_key: nil
    )
      url = path
      url = add_query_params_to_url(url, query)
      resulting_headers = default_headers.merge(headers).merge(auth_header(api_key))
      serialized_payload = payload&.to_json

      { method: method, url: url, payload: serialized_payload, headers: resulting_headers, timeout: timeout }
    end

    # Sets the default headers for API requests.
    def default_headers
      @default_headers ||= {
        "X-Nylas-API-Wrapper" => "ruby",
        "User-Agent" => "Nylas Ruby SDK #{Nylas::VERSION} - #{RUBY_VERSION}",
        "Content-type" => "application/json"
      }
    end

    # Parses the response from the Nylas API.
    def parse_response(response)
      return response if response.is_a?(Enumerable)

      Yajl::Parser.new(symbolize_names: true).parse(response)
    rescue Yajl::ParseError
      raise Nylas::JsonParseError
    end

    private

    # Sends a request to the Nylas REST API.
    #
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch.
    # @param url [String] URL for the API call.
    # @param headers [Hash] HTTP headers to include in the payload.
    # @param payload [String, Hash] Body to send with the request.
    # @param timeout [Hash] Timeout value to send with the request.
    def rest_client_execute(method:, url:, headers:, payload:, timeout:, &block)
      ::RestClient::Request.execute(method: method, url: url, payload: payload,
                                    headers: headers, timeout: timeout, &block)
    end

    # Handles failed responses from the Nylas API.
    def handle_failed_response(result, response, path)
      http_code = result.code.to_i

      handle_anticipated_failure_mode(http_code, response, path)
    end

    # Handles anticipated failure states in the Nylas API.
    def handle_anticipated_failure_mode(http_code, response, path)
      return if HTTP_SUCCESS_CODES.include?(http_code)

      case response
      when Hash
        raise error_hash_to_exception(response, http_code, path)
      else
        raise NylasApiError.parse_error_response(response, http_code)
      end
    end

    # Converts error hashes to exceptions.
    def error_hash_to_exception(response, status_code, path)
      return if !response || !response.key?(:error)

      if %W[#{api_uri}/v3/connect/token #{api_uri}/v3/connect/revoke].include?(path)
        NylasOAuthError.new(response[:error], response[:error_description], response[:error_uri],
                            response[:error_code], status_code)
      else
        error_obj = response[:error]
        provider_error = error_obj.fetch(:provider_error, nil)

        NylasApiError.new(error_obj[:type], error_obj[:message], status_code, provider_error,
                          response[:request_id])
      end
    end

    # Adds query parameters to a URL.
    #
    # @return [String] Processed URL, including query params.
    def add_query_params_to_url(url, query)
      unless query.empty?
        uri = URI.parse(url)
        query = custom_params(query)
        params = URI.decode_www_form(uri.query || "") + query.to_a
        uri.query = URI.encode_www_form(params)
        url = uri.to_s
      end

      url
    end

    # Defines custom parameters for a metadata_pair query.
    #
    # @return [String] Custom parameter in "<key>:<value>" format.
    def custom_params(query)
      # Convert hash to "<key>:<value>" form for metadata_pair query.
      if query.key?(:metadata_pair)
        pairs = query[:metadata_pair].map do |key, value|
          "#{key}:#{value}"
        end
        query[:metadata_pair] = pairs
      end

      query
    end

    # Set the authorization header for an API query.
    def auth_header(api_key)
      { "Authorization" => "Bearer #{api_key}" }
    end
  end
end
