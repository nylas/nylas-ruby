module Nylas
  module V1
    class SDK
      attr_accessor :client

      extend Forwardable
      def_delegators :client, :api_server=, :api_server, :access_token, :app_id, :app_secret

      def initialize(client:)
        self.client = client
      end

      def token_for_code(code)
        client.oauth_exchange_code_for_access_token(code)
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

      NoAuthToken = Class.new(Error)
      def url_for_path(path)
        raise NoAuthToken.new if access_token == nil and (app_secret != nil or app_id != nil)
        protocol, domain = api_server.split('//')
        "#{protocol}//#{access_token}:@#{domain}#{path}"
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

        "https://#{@service_domain}/oauth/authorize?" + HashToQuery.new(params).to_s
      end

      def url_for_management
        protocol, domain = @api_server.split('//')
        accounts_path = "#{protocol}//#{@app_secret}:@#{domain}/a/#{@app_id}/accounts"
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
        "account" => Account,
        "calendar" => Calendar,
        "draft" => Draft,
        "thread" => Thread,
        "contact" => Contact,
        "event" => Event,
        "file" => File,
        "message" => Message,
        "folder" => Folder,
        "label" => Label,
      }

      # It's possible to ask the API to expand objects.
      # In this case, we do the right thing and return
      # an expanded object.
      EXPANDED_OBJECTS_TABLE = {
        "message" => ExpandedMessage,
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

      require 'nylas/v1/delta_stream'
    end
  end
end
