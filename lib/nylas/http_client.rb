# frozen_string_literal: true

module Nylas
  require "yajl"
  require "base64"

  # Plain HTTP client that can be used to interact with the Nylas API sans any type casting.
  class HttpClient
    module AuthMethod
      BEARER = 1
      BASIC = 2
    end

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

    ENDPOINT_TIMEOUTS = {
      "/oauth/authorize" => 345,
      "/messages/search" => 350,
      "/threads/search" => 350,
      "/delta" => 3650,
      "/delta/longpoll" => 3650,
      "/delta/streaming" => 3650
    }.freeze

    SUPPORTED_API_VERSION = "2.5"

    include Logging
    attr_accessor :api_server
    attr_writer :default_headers
    attr_reader :access_token
    attr_reader :app_id
    attr_reader :app_secret

    # @param app_id [String] Your application id from the Nylas Dashboard
    # @param app_secret [String] Your application secret from the Nylas Dashboard
    # @param access_token [String] (Optional) Your users access token.
    # @param api_server [String] (Optional) Which Nylas API Server to connect to. Only change this if
    #                            you're using a self-hosted Nylas instance.
    # @return [Nylas::HttpClient]
    def initialize(app_id:, app_secret:, access_token: nil, api_server: "https://api.nylas.com")
      unless api_server.include?("://")
        raise "When overriding the Nylas API server address, you must include https://"
      end

      @api_server = api_server
      @access_token = access_token
      @app_secret = app_secret
      @app_id = app_id
    end

    # @return [Nylas::HttpClient[]
    def as(access_token)
      HttpClient.new(app_id: app_id, access_token: access_token,
                     app_secret: app_secret, api_server: api_server)
    end

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
    def execute(method:, path: nil, headers: {}, query: {}, payload: nil, auth_method: nil)
      timeout = ENDPOINT_TIMEOUTS.fetch(path, 230)
      request = build_request(
        method: method,
        path: path,
        headers: headers,
        query: query,
        payload: payload,
        timeout: timeout,
        auth_method: auth_method || AuthMethod::BEARER
      )
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
    # rubocop:enable Metrics/MethodLength
    inform_on :execute, level: :debug,
                        also_log: { result: true, values: %i[method url path headers query payload] }

    def build_request(
      method:,
      path: nil,
      headers: {},
      query: {},
      payload: nil,
      timeout: nil,
      auth_method: nil
    )
      url ||= url_for_path(path)
      url = add_query_params_to_url(url, query)
      resulting_headers = default_headers.merge(headers).merge(auth_header(auth_method))
      { method: method, url: url, payload: payload, headers: resulting_headers, timeout: timeout }
    end

    # Syntactical sugar for making GET requests via the API.
    # @see #execute
    def get(path: nil, headers: {}, query: {}, auth_method: nil)
      execute(method: :get, path: path, query: query, headers: headers, auth_method: auth_method)
    end

    # Syntactical sugar for making POST requests via the API.
    # @see #execute
    def post(path: nil, payload: nil, headers: {}, query: {}, auth_method: nil)
      execute(
        method: :post,
        path: path,
        headers: headers,
        query: query,
        payload: payload,
        auth_method: auth_method
      )
    end

    # Syntactical sugar for making PUT requests via the API.
    # @see #execute
    def put(path: nil, payload:, headers: {}, query: {}, auth_method: nil)
      execute(
        method: :put,
        path: path,
        headers: headers,
        query: query,
        payload: payload,
        auth_method: auth_method
      )
    end

    # Syntactical sugar for making DELETE requests via the API.
    # @see #execute
    def delete(path: nil, payload: nil, headers: {}, query: {}, auth_method: nil)
      execute(
        method: :delete,
        path: path,
        headers: headers,
        query: query,
        payload: payload,
        auth_method: auth_method
      )
    end

    def default_headers
      @default_headers ||= {
        "X-Nylas-API-Wrapper" => "ruby",
        "X-Nylas-Client-Id" => @app_id,
        "Nylas-API-Version" => SUPPORTED_API_VERSION,
        "User-Agent" => "Nylas Ruby SDK #{Nylas::VERSION} - #{RUBY_VERSION}",
        "Content-type" => "application/json"
      }
    end

    def parse_response(response)
      return response if response.is_a?(Enumerable)

      json = StringIO.new(response)
      Yajl::Parser.new(symbolize_names: true).parse(json)
    rescue Yajl::ParseError
      raise Nylas::JsonParseError
    end
    inform_on :parse_response, level: :debug, also_log: { result: true }

    def url_for_path(path)
      protocol, domain = api_server.split("//")
      "#{protocol}//#{access_token}:@#{domain}#{path}"
    end

    private

    def rest_client_execute(method:, url:, headers:, payload:, timeout:, &block)
      ::RestClient::Request.execute(method: method, url: url, payload: payload,
                                    headers: headers, timeout: timeout, &block)
    end

    inform_on :rest_client_execute, level: :debug,
                                    also_log: { result: true, values: %i[method url headers payload] }

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
        response[:type],
        response[:message],
        response.fetch(:server_error, nil)
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

    def auth_header(auth_method)
      authorization_string = case auth_method
                             when AuthMethod::BEARER
                               "Bearer #{access_token}"
                             when AuthMethod::BASIC
                               "Basic #{Base64.encode64("#{access_token}:")}"
                             else
                               "Bearer #{access_token}"
                             end

      { "Authorization" => authorization_string }
    end
  end
end
