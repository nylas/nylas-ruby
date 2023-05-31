# frozen_string_literal: true

require "rest-client"

require_relative "../errors"
require_relative "../version"

module Nylas
  require "yajl"
  require "base64"

  # Plain HTTP client that can be used to interact with the Nylas API sans any type casting.
  module HttpClient
    HTTP_SUCCESS_CODES = [200, 201, 202, 302].freeze

    HTTP_CODE_TO_EXCEPTIONS = {
      400 => InvalidRequest,
      401 => UnauthorizedRequest,
      402 => MessageRejected,
      403 => AccessDenied,
      404 => ResourceNotFound,
      405 => MethodNotAllowed,
      410 => ResourceRemoved,
      418 => TeapotError,
      422 => MailProviderError,
      429 => SendingQuotaExceeded,
      500 => InternalError,
      501 => EndpointNotYetImplemented,
      502 => BadGateway,
      503 => ServiceUnavailable,
      504 => RequestTimedOut
    }.freeze

    attr_accessor :api_server
    attr_writer :default_headers

    # Sends a request to the Nylas API and rai
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch
    # @param path [String] (Optional, defaults to nil) - Relative path from the API Base. Preferred way to
    #                      execute arbitrary or-not-yet-SDK-ified API commands.
    # @param headers [Hash] (Optional, defaults to {}) - Additional HTTP headers to include in the payload.
    # @param query [Hash] (Optional, defaults to {}) - Hash of names and values to include in the query
    #                      section of the URI fragment
    # @param payload [String,Hash] (Optional, defaults to nil) - Body to send with the request.
    # @param auth_method [AuthMethod] (Optional, defaults to BEARER) - The authentication method.
    # @return [Array Hash Stringn]
    # rubocop:disable Metrics/MethodLength
    def execute(method:, path: nil, headers: {}, query: {}, payload: nil, api_key: nil)
      request = build_request(method: method, path: path, headers: headers,
                              query: query, payload: payload, api_key: api_key)
      rest_client_execute(**request) do |response, _request, result|
        content_type = nil

        if response.headers && response.headers[:content_type]
          content_type = response.headers[:content_type].downcase
        end

        begin
          response = parse_response(response) if content_type == "application/json"
        rescue Nylas::JsonParseError
          handle_failed_response(result: result, response: response)
          raise
        end

        handle_failed_response(result: result, response: response)
        response
      end
    end

    def build_request(
      method:, path: nil, headers: {}, query: {}, payload: nil, timeout: nil, api_key: nil
    )
      url = path
      url = add_query_params_to_url(url, query)
      resulting_headers = default_headers.merge(headers).merge(auth_header(api_key))
      { method: method, url: url, payload: payload, headers: resulting_headers, timeout: timeout }
    end

    def default_headers
      @default_headers ||= {
        "X-Nylas-API-Wrapper" => "ruby",
        "User-Agent" => "Nylas Ruby SDK #{Nylas::VERSION} - #{RUBY_VERSION}",
        "Content-type" => "application/json"
      }
    end

    def parse_response(response)
      return response if response.is_a?(Enumerable)

      Yajl::Parser.new(symbolize_names: true).parse(response)
    rescue Yajl::ParseError
      raise Nylas::JsonParseError
    end

    private

    def rest_client_execute(method:, url:, headers:, payload:, timeout:, &block)
      ::RestClient::Request.execute(method: method, url: url, payload: payload,
                                    headers: headers, timeout: timeout, &block)
    end

    def handle_failed_response(result:, response:)
      http_code = result.code.to_i

      handle_anticipated_failure_mode(http_code: http_code, response: response)
      raise UnexpectedResponse, result.msg if result.is_a?(Net::HTTPClientError)
    end

    def handle_anticipated_failure_mode(http_code:, response:)
      return if HTTP_SUCCESS_CODES.include?(http_code)

      exception = HTTP_CODE_TO_EXCEPTIONS.fetch(http_code, APIError)
      case response
      when Hash
        raise error_hash_to_exception(exception, response)
      when RestClient::Response
        raise exception.parse_error_response(response)
      else
        raise exception.new(http_code, response)
      end
    end

    def error_hash_to_exception(exception, response)
      exception.new(
        response[:type], response[:message], response.fetch(:server_error, nil)
      )
    end

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

    def custom_params(query)
      # Convert hash to "<key>:<value>" form for metadata_pair query
      if query.key?(:metadata_pair)
        pairs = query[:metadata_pair].map do |key, value|
          "#{key}:#{value}"
        end
        query[:metadata_pair] = pairs
      end

      query
    end

    def auth_header(api_key)
      { "Authorization" => "Bearer #{api_key}" }
    end
  end
end
