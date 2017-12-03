module Nylas
  # This class currently conflates the HTTP client with the methods available. The methods for retrieving
  # actual objects from the API may be pulled up into a {Nylas::Legacy::SDK} and a {Nylas::SDK} that takes
  # responsibility for exposing which API endpoints are Ruby-ified in what way. Alternatively, we could pull
  # the get/post/put/execute stuff out into a {Nylas::Client} class that returns only Array's and Hashes. Will
  # figure that out before releasing 4.0 full.
  class API
    include Logging

    attr_accessor :api_server
    attr_accessor :api_version
    attr_accessor :version
    attr_reader :access_token
    attr_reader :app_id
    attr_reader :app_secret

    # Allow our friends with many API instantiations sprinkled throughout their codebase to make a very small
    # change in each of those places when upgrading to 4.0, while still granting priority to those who want to
    # dive into keyword args.
    # @deprecated Will be removed in Nylas 5.0
    def self.deprecated_new(app_id, app_secret, access_token=nil, api_server='https://api.nylas.com',
                            service_domain='api.nylas.com')
      new(app_id: app_id, app_secret: app_secret, access_token: access_token, api_server: api_server,
          service_domain: service_domain)
    end

    # @param app_id [String] Your application id from the Nylas Dashboard
    # @param app_secret [String] Your application secret from the Nylas Dashboard
    # @param access_token [String] (Optional) Your users access token.
    # @param api_server [String] (Optional) Which Nylas API Server to connect to. Only change this if
    #                            you're using a self-hosted Nylas instance.
    # @param service_domain [String] (Optional) Host you are authenticating OAuth against.
    # @param api_version [String] (Optional) Which version of the API you are using. Make sure this reflects
    #                             the API Version setting in the Nylas Dashboard.
    # @return [Nylas::API]
    def initialize(app_id: , app_secret:, access_token: nil, api_server: 'https://api.nylas.com',
                   service_domain: 'api.nylas.com', api_version: "1")
      raise "When overriding the Nylas API server address, you must include https://" unless api_server.include?('://')
      self.api_version = api_version
      @api_server = api_server
      @access_token = access_token
      @app_secret = app_secret
      @app_id = app_id
      @service_domain = service_domain
      @version = Nylas::VERSION
      @default_headers = {
        'X-Nylas-API-Wrapper' => 'ruby',
        'User-Agent' => "Nylas Ruby SDK #{@version} - #{RUBY_VERSION}",
        'Content-types' => 'application/json'
      }
    end

    # Sends a request to the Nylas API and rai
    # @param method [Symbol] HTTP method for the API call. Either :get, :post, :delete, or :patch
    # @param url [String] (Optional, defaults to nil) - Full URL to access. Deprecated and will be removed in
    #                     5.0.
    # @param path [String] (Optional, defaults to nil) - Relative path from the API Base. Preferred way to
    #                      execute arbitrary or-not-yet-SDK-ified API commands.
    # @param headers [Hash] (Optional, defaults to {}) - Additional HTTP headers to include in the payload.
    # @param query [Hash] (Optional, defaults to {}) - Hash of names and values to include in the query
    #                      section of the URI fragment
    # @param payload [String,Hash] (Optional, defaults to nil) - Body to send with the request.
    # @return [String Array Hash Nylas::V2::Model Nylas::V2::Collection Nylas::RestfulModel
    #          Nylas::RestfulModelCollection]
    # @yield (response, request, result) Pass through of {RestClient::Request.execute. See the RestClient
    #                                    gem's documentation for your particular version for details.
    # @yieldreturn [Array Hash Nylas::V2::Model Nylas::V2::Collection Nylas::RestfulModel Nylas::RestfulModelCollection]
    #   This depends on the context of the caller, the legacy SDK will likely return
    #   {Nylas::RestfulModel} or a {Nylas::RestfulModelCollection}, the modernized SDK will return a
    #   {Nylas::V2::Model} or a {Nylas::V2::Collection}, while those calling this directly will want likely
    #   return Array's of Hashes with symbols for keys.
    def execute(method: , url: nil, path: nil, headers: {}, query: {}, payload: nil, &block)
      headers[:params] = query
      url = url || url_for_path(path)
      resulting_headers = @default_headers.merge(headers)
      rest_client_execute(method: method, url: url, payload: payload,
                          headers: resulting_headers) do |response, request, result|
        self.class.raise_exception_for_failed_request(result: result, response: response, request: request)
        if block_given?
          yield(response, request, result)
        elsif method == :delete
          response
        else
          JSON.parse(response, symbolize_names: true)
        end
      end
    end
    inform_on :execute, level: :debug,
      also_log: { result: true, values: [:method, :url, :path, :headers, :query, :payload] }

    private def rest_client_execute(method: , url: , headers: , payload: , &block)
      ::RestClient::Request.execute(method: method, url: url, payload: payload,
                                    headers: headers, &block)
    end
    inform_on :rest_client_execute, level: :debug,
      also_log: { result: true, values: [:method, :url, :headers, :payload] }


    # Syntactical sugar for making GET requests via the API.
    # @see #execute
    def get(path: nil, url: nil, headers: {}, query: {}, &block)
      execute(method: :get, path: path, query: query, url: url, headers: headers, &block)
    end

    # Syntactical sugar for making POST requests via the API.
    # @see #execute
    def post(path: nil, url: nil, payload: nil, headers: {}, query: {}, &block)
      execute(method: :post, path: path, url: url, headers: headers, query: query, payload: payload, &block)
    end

    # Syntactical sugar for making PUT requests via the API.
    # @see #execute
    def put(path: nil, url: nil, payload: ,headers: {}, query: {}, &block)
      execute(method: :put, path: path, url: url, headers: headers, query: query, payload: payload, &block)
    end

    # Syntactical sugar for making DELETE requests via the API.
    # @see #execute
    def delete(path: nil, url: nil, payload: nil, headers: {}, query: {}, &block)
      execute(method: :delete, path: path, url: url, headers: headers, query: query, &block)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0.
    def url_for_path(path)
      raise NoAuthToken.new if @access_token == nil and (@app_secret != nil or @app_id != nil)
      protocol, domain = @api_server.split('//')
      "#{protocol}//#{@access_token}:@#{domain}#{path}"
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def url_for_authentication(redirect_uri, login_hint = '', options = {})
      query = {
        :client_id => @app_id,
        :trial => options.fetch(:trial, false),
        :response_type => 'code',
        :scope => 'email',
        :login_hint => login_hint,
        :redirect_uri => redirect_uri,
      }

      if options.has_key?(:state) then
        query[:state] = options[:state]
      end

      "https://#{@service_domain}/oauth/authorize?" + ToQuery.new(query).to_s
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def url_for_management
      protocol, domain = @api_server.split('//')
      accounts_path = "#{protocol}//#{@app_secret}:@#{domain}/a/#{@app_id}/accounts"
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def set_access_token(token)
      @access_token = token
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def token_for_code(code)
      data = {
        'client_id' => app_id,
        'client_secret' => app_secret,
        'grant_type' => 'authorization_code',
        'code' => code
      }

      post(url: "https://#{@service_domain}/oauth/token", payload: data) do |response, _request, result|
        json = API.interpret_response(result, response, expected_class: Object)
        return json['access_token']
      end
    end

    # API Methods
    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def threads
      @threads ||= RestfulModelCollection.new(Thread, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def messages(expanded: false)
      @messages ||= Hash.new do |h, is_expanded|
        h[is_expanded] = \
          if is_expanded
            RestfulModelCollection.new(ExpandedMessage, self, view: 'expanded')
        else
          RestfulModelCollection.new(Message, self)
        end
      end
      @messages[expanded]
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def files
      @files ||= RestfulModelCollection.new(File, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def contacts
      if api_version == "2"
        @contants ||= V2::Collection.new(model: V2::Contact, api:self)
      else
        @contacts ||= RestfulModelCollection.new(Contact, self)
      end
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def calendars
      @calendars ||= RestfulModelCollection.new(Calendar, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def events
      @events ||= RestfulModelCollection.new(Event, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def folders
      @folders ||= RestfulModelCollection.new(Folder, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def labels
      @labels ||= RestfulModelCollection.new(Label, self)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def account
      url = self.url_for_path("/account")

      get(url: url) do |response, _request, result|
        json = API.interpret_response(result, response, expected_class: Object)
        model = APIAccount.new(self)
        model.inflate(json)
        model
      end
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def using_hosted_api?
      return !@app_id.nil?
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def accounts
      if self.using_hosted_api?
        @accounts ||= ManagementModelCollection.new(Account, self)
      else
        @accounts ||= RestfulModelCollection.new(APIAccount, self)
      end
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def latest_cursor
      # Get the cursor corresponding to a specific timestamp.
      path = self.url_for_path("/delta/latest_cursor")

      cursor = nil

      post(url: path, headers: { content_type: :json }) do |response, _request, result|
        json = API.interpret_response(result, response, expected_class: Object)
        cursor = json["cursor"]
      end

      cursor
    end

    OBJECTS_TABLE = {
      "account" => Nylas::Account,
      "calendar" => Nylas::Calendar,
      "draft" => Nylas::Draft,
      "thread" => Nylas::Thread,
      "contact" => Nylas::Contact,
      "event" => Nylas::Event,
      "file" => Nylas::File,
      "message" => Nylas::Message,
      "folder" => Nylas::Folder,
      "label" => Nylas::Label,
    }

    # It's possible to ask the API to expand objects.
    # In this case, we do the right thing and return
    # an expanded object.
    EXPANDED_OBJECTS_TABLE = {
      "message" => Nylas::ExpandedMessage,
    }

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def deltas(cursor, exclude_types=[], expanded_view=false, include_types=[])
      return enum_for(:deltas, cursor, exclude_types, expanded_view, include_types) unless block_given?

      exclude_string = TypesFilter.new(:exclude, types: exclude_types).to_query_string
      include_string = TypesFilter.new(:include, types: include_types).to_query_string

      # loop and yield deltas until we've come to the end.
      loop do
        url = self.url_for_path("/delta?exclude_folders=false&cursor=#{cursor}#{exclude_string}#{include_string}")
        if expanded_view
          url += '&view=expanded'
        end

        json = nil

        get(url: url) do |response, _request, result|
          json = API.interpret_response(result, response, expected_class: Object)
        end

        start_cursor = json["cursor_start"]
        end_cursor = json["cursor_end"]

        json["deltas"].each do |delta|
          if not OBJECTS_TABLE.has_key?(delta['object'])
            next
          end

          cls = OBJECTS_TABLE[delta['object']]
          if EXPANDED_OBJECTS_TABLE.has_key?(delta['object']) and expanded_view
            cls = EXPANDED_OBJECTS_TABLE[delta['object']]
          end

          obj = cls.new(self)

          case delta["event"]
          when 'create', 'modify'
            obj.inflate(delta['attributes'])
            obj.cursor = delta["cursor"]
            yield delta["event"], obj
          when 'delete'
            obj.id = delta["id"]
            obj.cursor = delta["cursor"]
            yield delta["event"], obj
          end
        end

        break if start_cursor == end_cursor
        cursor = end_cursor
      end
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def delta_stream(cursor, exclude_types=[], timeout=0, expanded_view=false, include_types=[], &block)
      raise NotImplementedError, "the `#delta_stream` method was removed in 4.0 in favor of using the " \
                                 "`nylas-streming` gem. This reduces the dependency footprint of the core " \
                                 "nylas gem for those not using the streaming API."
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def self.interpret_response(result, result_content, result_parsed: nil, expected_class: nil, raw_response: nil, request: nil)
      # We expected a certain kind of object, but the API didn't return anything
      raise UnexpectedResponse.new if expected_class && result_content.empty?

      # If it's already parsed, or if we've received an actual raw payload on success, don't parse
      if result_parsed || (raw_response && result.code.to_i == 200)
        response = result_content
      else
        response = JSON.parse(result_content)
      end

      raise_exception_for_failed_request(result: result, response: response, request: request)
      raise UnexpectedResponse.new if expected_class && !response.is_a?(expected_class)
      response

    rescue JSON::ParserError => e
      # Handle parsing errors
      raise UnexpectedResponse.new(e.message)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def self.http_code_to_exception(http_code)
      HTTP_CODE_TO_EXCEPTIONS.fetch(http_code, APIError)
    end

    # @deprecated Likely to be moved elsewhere in Nylas SDK 5.0
    def self.raise_exception_for_failed_request(result: , response:, request:)
      response = begin
                   response.kind_of?(Enumerable) ? response : JSON.parse(response)
                 rescue JSON::ParserError
                   response
                 end
      if result.code.to_i != 200
        exc = http_code_to_exception(result.code.to_i)
        if response.is_a?(Hash)
          raise exc.new(response['type'], response['message'], response.fetch('server_error', nil))
        end
      end

      raise UnexpectedResponse.new(result.msg) if result.is_a?(Net::HTTPClientError)
    end
  end
end
