# frozen_string_literal: true

require "httparty"
require "net/http"

require_relative "../errors"
require_relative "../version"

# Module for working with HTTP Client
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
    # @param timeout [Integer, nil] Timeout value to send with the request.
    # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
    # @param query [Hash, {}] Hash of names and values to include in the query section of the URI
    # fragment.
    # @param payload [Hash, nil] Body to send with the request.
    # @param api_key [Hash, nil] API key to send with the request.
    # @return [Object] Parsed JSON response from the API.
    def execute(method:, path:, timeout:, headers: {}, query: {}, payload: nil, api_key: nil)
      request = build_request(method: method, path: path, headers: headers,
                              query: query, payload: payload, api_key: api_key, timeout: timeout)
      begin
        httparty_execute(**request) do |response, _request, result|
          content_type = nil
          if response.headers && response.headers["content-type"]
            content_type = response.headers["content-type"].downcase
          end

          parsed_response = parse_json_evaluate_error(result.code.to_i, response.body, path, content_type, response.headers)
          # Include headers in the response
          parsed_response[:headers] = response.headers unless parsed_response.nil?
          parsed_response
        end
      rescue Net::OpenTimeout, Net::ReadTimeout
        raise Nylas::NylasSdkTimeoutError.new(request[:path], timeout)
      end
    end

    # Sends a request to the Nylas API, specifically for downloading data.
    # This method supports streaming the response by passing a block, which will be executed
    # with each chunk of the response body as it is read. If no block is provided, the entire
    # response body is returned.
    #
    # @param path [String] Relative path from the API Base. This is the preferred way to execute
    # arbitrary or-not-yet-SDK-ified API commands.
    # @param timeout [Integer] Timeout value to send with the request.
    # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
    # @param query [Hash, {}] Hash of names and values to include in the query section of the URI
    # fragment.
    # @param api_key [Hash, nil] API key to send with the request.
    # @yieldparam chunk [String] A chunk of the response body.
    # @return [nil, String] Returns nil when a block is given (streaming mode).
    #     When no block is provided, the return is the entire raw response body.
    def download_request(path:, timeout:, headers: {}, query: {}, api_key: nil, &block)
      request, uri, http = setup_http(path, timeout, headers, query, api_key)

      begin
        http.start do |setup_http|
          get_request = Net::HTTP::Get.new(uri)
          request[:headers].each { |key, value| get_request[key] = value }

          handle_response(setup_http, get_request, path, &block)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout
        raise Nylas::NylasSdkTimeoutError.new(request[:url], timeout)
      end
    end

    # Builds a request sent to the Nylas API.
    #
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch.
    # @param path [String, nil] Relative path from the API Base.
    # @param headers [Hash, {}] Additional HTTP headers to include in the payload.
    # @param query [Hash, {}] Hash of names and values to include in the query section of the URI
    # fragment.
    # @param payload [Hash, nil] Body to send with the request.
    # @param timeout [Integer, nil] Timeout value to send with the request.
    # @param api_key [Hash, nil] API key to send with the request.
    # @return [Object] The request information after processing. This includes an updated payload
    # and headers.
    def build_request(
      method:, path: nil, headers: {}, query: {}, payload: nil, timeout: nil, api_key: nil
    )
      url = build_url(path, query)
      resulting_headers = default_headers.merge(headers).merge(auth_header(api_key))

      # Check for multipart flag using both string and symbol keys for backwards compatibility
      is_multipart = !payload.nil? && (payload["multipart"] || payload[:multipart])

      if !payload.nil? && !is_multipart
        normalize_json_encodings!(payload)
        payload = payload&.to_json
        resulting_headers["Content-type"] = "application/json"
      elsif is_multipart
        # Remove multipart flag from both possible key types
        payload.delete("multipart")
        payload.delete(:multipart)
      end

      { method: method, url: url, payload: payload, headers: resulting_headers, timeout: timeout }
    end

    # Sets the default headers for API requests.
    def default_headers
      @default_headers ||= {
        "X-Nylas-API-Wrapper" => "ruby",
        "User-Agent" => "Nylas Ruby SDK #{Nylas::VERSION} - #{RUBY_VERSION}"
      }
    end

    # Parses the response from the Nylas API.
    def parse_response(response)
      return response if response.is_a?(Enumerable)

      Yajl::Parser.new(symbolize_names: true).parse(response) || raise(Nylas::JsonParseError)
    rescue Yajl::ParseError
      raise Nylas::JsonParseError
    end

    private

    # Sends a request to the Nylas REST API using HTTParty.
    #
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch.
    # @param url [String] URL for the API call.
    # @param headers [Hash] HTTP headers to include in the payload.
    # @param payload [String, Hash] Body to send with the request.
    # @param timeout [Hash] Timeout value to send with the request.
    def httparty_execute(method:, url:, headers:, payload:, timeout:)
      options = {
        headers: headers,
        timeout: timeout
      }

      # Handle multipart uploads
      if payload.is_a?(Hash) && file_upload?(payload)
        options[:multipart] = true
        options[:body] = prepare_multipart_payload(payload)
      elsif payload
        options[:body] = payload
      end

      response = HTTParty.send(method, url, options)

      # Create a compatible response object that mimics RestClient::Response
      result = create_response_wrapper(response)

      # Call the block with the response in the same format as rest-client
      if block_given?
        yield response, nil, result
      else
        response
      end
    end

    # Create a response wrapper that mimics RestClient::Response.code behavior
    def create_response_wrapper(response)
      OpenStruct.new(code: response.code)
    end

    # Check if payload contains file uploads
    def file_upload?(payload)
      return false unless payload.is_a?(Hash)

      # Check for traditional file uploads (File objects or objects that respond to :read)
      has_file_objects = payload.values.any? do |value|
        value.respond_to?(:read) || (value.is_a?(File) && !value.closed?)
      end

      return true if has_file_objects

      # Check if payload was prepared by FileUtils.build_form_request for multipart uploads
      # This handles binary content attachments that are strings with added singleton methods
      has_message_field = payload.key?("message") && payload["message"].is_a?(String)
      has_attachment_fields = payload.keys.any? { |key| key.is_a?(String) && key.match?(/^file\d+$/) }

      # If we have both a "message" field and "file{N}" fields, this indicates
      # the payload was prepared by FileUtils.build_form_request for multipart upload
      has_message_field && has_attachment_fields
    end

    # Prepare multipart payload for HTTParty compatibility
    # HTTParty requires all multipart fields to have compatible encodings
    def prepare_multipart_payload(payload)
      require "stringio"

      modified_payload = payload.dup

      # First, normalize all string encodings to prevent HTTParty encoding conflicts
      normalize_multipart_encodings!(modified_payload)

      # Handle binary content attachments (file0, file1, etc.) by converting them to enhanced StringIO
      # HTTParty expects file uploads to be objects with full file-like interface
      modified_payload.each do |key, value|
        next unless key.is_a?(String) && key.match?(/^file\d+$/) && value.is_a?(String)

        # Get the original value to check for singleton methods
        original_value = payload[key]

        # Create an enhanced StringIO object for HTTParty compatibility
        string_io = create_file_like_stringio(value)

        # Preserve filename and content_type if they exist as singleton methods
        if original_value.respond_to?(:original_filename)
          string_io.define_singleton_method(:original_filename) { original_value.original_filename }
        end

        if original_value.respond_to?(:content_type)
          string_io.define_singleton_method(:content_type) { original_value.content_type }
        end

        modified_payload[key] = string_io
      end

      modified_payload
    end

    # Normalize string encodings in multipart payload to prevent HTTParty encoding conflicts
    # This ensures all string fields use consistent ASCII-8BIT encoding for multipart compatibility
    def normalize_multipart_encodings!(payload)
      payload.each do |key, value|
        next unless value.is_a?(String)

        # Force all string values to ASCII-8BIT encoding for multipart compatibility
        # HTTParty/multipart-post expects binary encoding for consistent concatenation
        payload[key] = value.dup.force_encoding(Encoding::ASCII_8BIT)
      end
    end

    # Normalize JSON encodings for attachment content to ensure binary data is base64 encoded.
    # This handles cases where users pass raw binary content directly instead of file objects.
    def normalize_json_encodings!(payload)
      return unless payload.is_a?(Hash)

      # Handle attachment content encoding for JSON serialization
      attachments = payload[:attachments] || payload["attachments"]
      return unless attachments

      attachments.each do |attachment|
        content = attachment[:content] || attachment["content"]
        next unless content.is_a?(String)

        # If content appears to be binary (non-UTF-8), base64 encode it
        next unless content.encoding == Encoding::ASCII_8BIT || !content.valid_encoding?

        encoded_content = Base64.strict_encode64(content)
        if attachment.key?(:content)
          attachment[:content] = encoded_content
        else
          attachment["content"] = encoded_content
        end
      end
    end

    # Create a StringIO object that behaves more like a File for HTTParty compatibility
    def create_file_like_stringio(content)
      # Content is already normalized to ASCII-8BIT by normalize_multipart_encodings!
      # Create StringIO with the normalized binary content
      string_io = StringIO.new(content)

      # Add methods that HTTParty/multipart-post might expect
      string_io.define_singleton_method(:path) { nil }
      string_io.define_singleton_method(:local_path) { nil }
      string_io.define_singleton_method(:respond_to_missing?) do |method_name, include_private = false|
        File.instance_methods.include?(method_name) || super(method_name, include_private)
      end

      # Set binary mode for file-like behavior
      string_io.binmode if string_io.respond_to?(:binmode)

      string_io
    end

    def setup_http(path, timeout, headers, query, api_key)
      request = build_request(method: :get, path: path, headers: headers,
                              query: query, api_key: api_key, timeout: timeout)
      uri = URI(request[:url])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = timeout
      http.open_timeout = timeout
      [request, uri, http]
    end

    def handle_response(http, get_request, path, &block)
      http.request(get_request) do |response|
        if response.is_a?(Net::HTTPSuccess)
          return response.body unless block_given?

          response.read_body(&block)
        else
          parse_json_evaluate_error(response.code.to_i, response.body, path, response["Content-Type"])
          break
        end
      end
    end

    # Parses the response from the Nylas API and evaluates for errors.
    def parse_json_evaluate_error(http_code, response, path, content_type = nil, headers = nil)
      begin
        response = parse_response(response) if content_type == "application/json"
      rescue Nylas::JsonParseError
        handle_failed_response(http_code, response, path, headers)
        raise
      end

      handle_failed_response(http_code, response, path, headers)
      response
    end

    # Handles failed responses from the Nylas API.
    def handle_failed_response(http_code, response, path, headers = nil)
      return if HTTP_SUCCESS_CODES.include?(http_code)

      case response
      when Hash
        raise error_hash_to_exception(response, http_code, path, headers)
      else
        raise NylasApiError.parse_error_response(response, http_code)
      end
    end

    # Converts error hashes to exceptions.
    def error_hash_to_exception(response, status_code, path, headers = nil)
      return if !response || !response.key?(:error)

      if %W[#{api_uri}/v3/connect/token #{api_uri}/v3/connect/revoke].include?(path)
        NylasOAuthError.new(response[:error], response[:error_description], response[:error_uri],
                            response[:error_code], status_code)
      else
        throw_error(response, status_code, headers)
      end
    end

    def throw_error(response, status_code, headers = nil)
      error_obj = response[:error]

      # If `error_obj` is just a string, turn it into a hash with default keys.
      if error_obj.is_a?(String)
        error_obj = {
          type: "NylasApiError",
          message: error_obj,
          headers: headers
        }
      end

      provider_error = error_obj.fetch(:provider_error, nil) if error_obj.is_a?(Hash)

      NylasApiError.new(
        error_obj[:type],
        error_obj[:message],
        status_code,
        provider_error,
        response[:request_id],
        headers
      )
    end

    # Adds query parameters to a URL.
    # @param url [String] The base URL.
    # @param query [Hash] The query parameters to add to the URL.
    # @return [String] Processed URL, including query params.
    def build_url(url, query = nil)
      unless query.nil? || query.empty?
        uri = URI.parse(url)
        uri = build_query(uri, query)
        url = uri.to_s
      end

      url
    end

    # Build the query string for a URI.
    # @param uri [URI] URL to add the query to.
    # @param query [Hash] The query params to include in the query.
    # @return [URI] The URI object with the query parameters included.
    def build_query(uri, query)
      query.each do |key, value|
        case value
        when Array
          value.each do |item|
            qs = "#{URI.encode_www_form_component(key)}=#{URI.encode_www_form_component(item)}"
            uri.query = [uri.query, qs].compact.join("&")
          end
        when Hash
          value.each do |k, v|
            qs = "#{URI.encode_www_form_component(key)}=#{URI.encode_www_form_component("#{k}:#{v}")}"
            uri.query = [uri.query, qs].compact.join("&")
          end
        else
          qs = "#{URI.encode_www_form_component(key)}=#{URI.encode_www_form_component(value)}"
          uri.query = [uri.query, qs].compact.join("&")
        end
      end

      uri
    end

    # Set the authorization header for an API query.
    def auth_header(api_key)
      { "Authorization" => "Bearer #{api_key}" }
    end
  end
end
