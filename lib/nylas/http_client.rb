require_relative 'version'
module Nylas
  # Makes requests and interprets responses into plain old hashes. Useful for making free-form interactions
  # with the Nylas API.
  class HttpClient
    attr_accessor :app_id, :app_secret, :access_token, :service_domain, :api_server
    def initialize(app_id:, app_secret:, access_token: nil, service_domain: 'api.nylas.com', api_server: 'https://api.nylas.com')
      self.api_server = api_server
      self.app_id = app_id
      self.app_secret = app_secret
      self.access_token = access_token
      self.service_domain = service_domain
    end

    def oauth_exchange_code_for_access_token(code)
      data = {
        'client_id' => app_id,
        'client_secret' => app_secret,
        'grant_type' => 'authorization_code',
        'code' => code
      }
      response = post(path: "/oauth/token", body: data)
      response.json['access_token']
    end

    def sdk_version
      VERSION
    end

    # Retrieves data from the API using the GET HTTP Method
    # @param path [String] Path to the resource you are requesting data from
    # @param query [Hash] Query parameters to pass to the API.
    # @param content_type [String] Defaults to "application/json"
    # @param additional_headers [Hash] Additional HTTP headers to pass into the API.
    # @see https://docs.nylas.com/reference#sending-raw-mime Example POSTing additional HTTP headers
    # @see https://docs.nylas.com/reference#get-events Example of GETting an index with additional query params
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type Explanation of content type headers
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET Explanation of HTTP GET Method
    def get(path, query: {}, content_type: 'application/json', additional_headers: {})
      request(:get, path, query: query, content_type: content_type ,additional_headers: additional_headers)
    end

    # Sends data to the API using the POST HTTP Method
    # @param path [String] Path to the resource you are requesting data from
    # @param query [Hash] Query parameters to pass to the API.
    # @param content_type [String] Defaults to "application/json"
    # @param additional_headers [Hash] Additional HTTP headers to pass into the API.
    # @see https://docs.nylas.com/reference#sending-raw-mime Example POSTing additional HTTP headers
    # @see https://docs.nylas.com/reference#get-events Example of GETting an index with additional query params
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type Explanation of content type headers
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST Explanation of HTTP POST Method
    def post(path, body: {}, query: {}, additional_headers: {})
      request(:post, path, body: body, query: query, additional_headers: additional_headers)
    end

    def request(method, path, query: {}, additional_headers: {})
      response = RestClient::Request.execute(method: method, headers: request_headers(additional_headers), url: url_for(path: path, query: query))
      return interpret_response(response, response.body)
    end

    private def http_code_to_exception(http_code)
      HTTP_CODE_TO_EXCEPTIONS.fetch(http_code, APIError)
    end

    private def interpret_response(result, result_content)
      # If it's already parsed, or if we've received an actual raw payload on success, don't parse
      if options[:result_parsed] || (options[:raw_response] && result.code.to_i == 200)
        response = result_content
      else
        response = JSON.parse(result_content)
      end

      if result.code.to_i != 200
        exc = http_code_to_exception(result.code.to_i)
        if response.is_a?(Hash)
          raise exc.new(response['type'], response['message'], response.fetch('server_error', nil))
        end
      end

      raise UnexpectedResponse.new(result.msg) if result.is_a?(Net::HTTPClientError)
      raise UnexpectedResponse.new if options[:expected_class] && !response.is_a?(options[:expected_class])
      response

    rescue JSON::ParserError => e
      # Handle parsing errors
      raise UnexpectedResponse.new(e.message)
    end


    private def url_for(path:, query: )
      URI::Generic.new(server_uri.scheme,
                       "#{access_token}:",
                       server_uri.host, nil, nil,
                       path, nil, cast_query_to_string(query), nil).to_s
    end

    private def cast_query_to_string(query)
      return query if query.kind_of? String
      return HashToQuery.new(query).to_s if query.kind_of? Hash

      raise TypeError, "unable to cast the passed in query object to a query string"
    end

    private def server_uri
      @server_uri ||= URI.parse(api_server)
    end


    private def request_headers(additional_headers)
      {
        'X-Nylas-API-Wrapper' => 'ruby',
        'User-Agent' => "Nylas Ruby SDK #{sdk_version} - #{RUBY_VERSION}"
      }.merge(additional_headers)
    end
  end
end
