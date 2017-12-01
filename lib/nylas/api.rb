module Nylas
  class API
    attr_accessor :api_server
    attr_accessor :api_version
    attr_accessor :version
    attr_reader :access_token
    attr_reader :app_id
    attr_reader :app_secret

    # Allow our friends with many API instantiations sprinkled throughout their codebase to make a very small
    # change in each of those places when upgrading to 4.0, while still granting priority to those who want to
    # dive into keyword args.
    def self.deprecated_new(app_id, app_secret, access_token=nil, api_server='https://api.nylas.com',
                        service_domain='api.nylas.com')
      new(app_id: app_id, app_secret: app_secret, access_token: access_token, api_server: api_server,
          service_domain: service_domain)
    end

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
        'User-Agent' => "Nylas Ruby SDK #{@version} - #{RUBY_VERSION}"
      }
    end

    def get(path: nil, url: nil, headers: {}, params: {}, &block)
      execute(method: :get, path: path, params: params, url: url, headers: headers, params: params, &block)
    end

    def post(path: nil, url: nil, payload: nil, headers: {}, params: {}, &block)
      execute(method: :post, path: path, url: url, headers: headers, params: params, payload: payload, &block)
    end

    def put(path: nil, url: nil, payload: ,headers: {}, params: {}, &block)
      execute(method: :put, path: path, url: url, headers: headers, params: params, payload: payload, &block)
    end

    def delete(path: nil, url: nil, payload: nil, headers: {}, params: {}, &block)
      execute(method: :delete, path: path, url: url, headers: headers, params: params, &block)
    end

    def execute(method: , url: nil, path: nil, headers: {}, params: {}, payload: nil, &block)
      headers[:params] = params
      url = url || url_for_path(path)
      ::RestClient::Request.execute(
        method: method,
        url: url,
        payload: payload,
        headers: @default_headers.merge(headers),
        &block
      )
    end

    def url_for_path(path)
      raise NoAuthToken.new if @access_token == nil and (@app_secret != nil or @app_id != nil)
      protocol, domain = @api_server.split('//')
      "#{protocol}//#{@access_token}:@#{domain}#{path}"
    end

    def url_for_authentication(redirect_uri, login_hint = '', options = {})
      params = {
        :client_id => @app_id,
        :trial => options.fetch(:trial, false),
        :response_type => 'code',
        :scope => 'email',
        :login_hint => login_hint,
        :redirect_uri => redirect_uri,
      }

      if options.has_key?(:state) then
        params[:state] = options[:state]
      end

      "https://#{@service_domain}/oauth/authorize?" + ToQuery.new(params).to_s
    end

    def url_for_management
      protocol, domain = @api_server.split('//')
      accounts_path = "#{protocol}//#{@app_secret}:@#{domain}/a/#{@app_id}/accounts"
    end

    def set_access_token(token)
      @access_token = token
    end

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
    def threads
      @threads ||= RestfulModelCollection.new(Thread, self)
    end

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

    def files
      @files ||= RestfulModelCollection.new(File, self)
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, self)
    end

    def contacts
      if api_version == "2"
        @contants ||= V2::Query.new(model: V2::Contact, api:self)
      else
        @contacts ||= RestfulModelCollection.new(Contact, self)
      end
    end

    def calendars
      @calendars ||= RestfulModelCollection.new(Calendar, self)
    end

    def events
      @events ||= RestfulModelCollection.new(Event, self)
    end

    def folders
      @folders ||= RestfulModelCollection.new(Folder, self)
    end

    def labels
      @labels ||= RestfulModelCollection.new(Label, self)
    end

    def account
      url = self.url_for_path("/account")

      get(url: url) do |response, _request, result|
        json = API.interpret_response(result, response, expected_class: Object)
        model = APIAccount.new(self)
        model.inflate(json)
        model
      end
    end

    def using_hosted_api?
      return !@app_id.nil?
    end

    def accounts
      if self.using_hosted_api?
        @accounts ||= ManagementModelCollection.new(Account, self)
      else
        @accounts ||= RestfulModelCollection.new(APIAccount, self)
      end
    end

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

    def delta_stream(cursor, exclude_types=[], timeout=0, expanded_view=false, include_types=[], &block)
      raise NotImplementedError, "the `#delta_stream` method was removed in 4.0 in favor of using the " \
                                 "`nylas-streming` gem. This reduces the dependency footprint of the core " \
                                 "nylas gem for those not using the streaming API."
    end

    def self.interpret_response(result, result_content, options = {})
      # We expected a certain kind of object, but the API didn't return anything
      raise UnexpectedResponse.new if options[:expected_class] && result_content.empty?

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

    def self.http_code_to_exception(http_code)
      HTTP_CODE_TO_EXCEPTIONS.fetch(http_code, APIError)
    end
  end
end
