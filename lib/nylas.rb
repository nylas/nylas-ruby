require 'json'
require 'rest-client'

require 'ostruct'
require_relative 'nylas/to_query'

require 'nylas/account'
require 'nylas/api_account'
require 'nylas/thread'
require 'nylas/calendar'
require 'nylas/account'
require 'nylas/message'
require 'nylas/expanded_message'
require 'nylas/draft'
require 'nylas/contact'
require 'nylas/file'
require 'nylas/calendar'
require 'nylas/event'
require 'nylas/folder'
require 'nylas/label'
require 'nylas/restful_model'
require 'nylas/restful_model_collection'
require 'nylas/version'

module Nylas
  Error = Class.new(::StandardError)
  NoAuthToken = Class.new(Error)
  UnexpectedAccountAction = Class.new(Error)
  UnexpectedResponse = Class.new(Error)
  class APIError < Error
    attr_accessor :type
    attr_accessor :message
    attr_accessor :server_error

    def initialize(type, message, server_error = nil)
      super(message)
      self.type = type
      self.message = message
      self.server_error = server_error
    end
  end
  AccessDenied = Class.new(APIError)
  ResourceNotFound = Class.new(APIError)
  InvalidRequest = Class.new(APIError)
  MessageRejected = Class.new(APIError)
  SendingQuotaExceeded = Class.new(APIError)
  ServiceUnavailable = Class.new(APIError)
  BadGateway = Class.new(APIError)
  InternalError = Class.new(APIError)
  MailProviderError = Class.new(APIError)

  HTTP_CODE_TO_EXCEPTIONS = {
    400 => InvalidRequest,
    402 => MessageRejected,
    403 => AccessDenied,
    404 => ResourceNotFound,
    422 => MailProviderError,
    429 => SendingQuotaExceeded,
    500 => InternalError,
    502 => BadGateway,
    503 => ServiceUnavailable,
  }.freeze

  def self.http_code_to_exception(http_code)
    HTTP_CODE_TO_EXCEPTIONS.fetch(http_code, APIError)
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
      exc = Nylas.http_code_to_exception(result.code.to_i)
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


  class API
    attr_accessor :api_server
    attr_reader :access_token
    attr_reader :app_id
    attr_reader :app_secret

    def initialize(app_id, app_secret, access_token = nil, api_server = 'https://api.nylas.com',
                   service_domain = 'api.nylas.com')
      raise "When overriding the Nylas API server address, you must include https://" unless api_server.include?('://')
      @api_server = api_server
      @access_token = access_token
      @app_secret = app_secret
      @app_id = app_id
      @service_domain = service_domain
      @version = Nylas::VERSION

      if ::RestClient.before_execution_procs.empty?
        ::RestClient.add_before_execution_proc do |req, params|
          req.add_field('X-Nylas-API-Wrapper', 'ruby')
          req['User-Agent'] = "Nylas Ruby SDK #{@version} - #{RUBY_VERSION}"
        end
      end
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

      ::RestClient.post("https://#{@service_domain}/oauth/token", data) do |response, request, result|
        json = Nylas.interpret_response(result, response, :expected_class => Object)
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
      @contacts ||= RestfulModelCollection.new(Contact, self)
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
      path = self.url_for_path("/account")

      RestClient.get(path, {}) do |response,request,result|
        json = Nylas.interpret_response(result, response, {:expected_class => Object})
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

      RestClient.post(path, :content_type => :json) do |response,request,result|
        json = Nylas.interpret_response(result, response, {:expected_class => Object})
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

    def _build_types_filter_string(filter, types)
      return "" if types.empty?
      query_string = "&#{filter}_types="

      types.each do |value|
        count = 0
        if OBJECTS_TABLE.has_value?(value)
          param_name = OBJECTS_TABLE.key(value)
          query_string += "#{param_name},"
        end
      end

      query_string = query_string[0..-2]
    end

    def deltas(cursor, exclude_types=[], expanded_view=false, include_types=[])
      return enum_for(:deltas, cursor, exclude_types, expanded_view, include_types) unless block_given?

      exclude_string = _build_types_filter_string(:exclude, exclude_types)
      include_string = _build_types_filter_string(:include, include_types)

      # loop and yield deltas until we've come to the end.
      loop do
        path = self.url_for_path("/delta?exclude_folders=false&cursor=#{cursor}#{exclude_string}#{include_string}")
        if expanded_view
          path += '&view=expanded'
        end

        json = nil

        RestClient.get(path) do |response,request,result|
          json = Nylas.interpret_response(result, response, {:expected_class => Object})
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

    require 'nylas/api/delta_stream'
  end
end
