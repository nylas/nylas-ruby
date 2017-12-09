require "yajl"
require "em-http"
require "nylas"

module Nylas
  class API
    def delta_stream(cursor, exclude_types = [], timeout = 0, expanded_view = false, include_types = [], &block)
      Streaming::Stream.new(api: self, cursor: cursor, timeout: timeout, expanded_view: expanded_view,
                            exclude_types: exclude_types, include_types: include_types).listen(&block)
    end
  end

  module Streaming
    class Stream
      extend Forwardable
      def_delegators :api, :url_for_path
      attr_accessor :api, :timeout, :expanded_view, :include_types, :exclude_types, :cursor

      def initialize(api:, cursor:, timeout: 0, expanded_view: false, include_types: [], exclude_types: [])
        self.api = api
        self.cursor = cursor
        self.timeout = timeout
        self.expanded_view = expanded_view
        self.include_types = TypesFilter.new(:include, types: include_types)
        self.exclude_types = TypesFilter.new(:exclude, types: exclude_types)
      end

      def listen
        raise "Please provide a block for receiving the delta objects" unless block_given?

        exclude_string = exclude_types.to_query_string
        include_string = include_types.to_query_string

        # loop and yield deltas indefinitely.
        path = url_for_path("/delta/streaming?exclude_folders=false&cursor=#{cursor}#{exclude_string}#{include_string}")
        path += "&view=expanded" if expanded_view

        parser = Yajl::Parser.new(symbolize_keys: false)
        parser.on_parse_complete = proc do |data|
          delta = Nylas.interpret_response(OpenStruct.new(code: "200"), data, expected_class: Object, result_parsed: true)

          next unless OBJECTS_TABLE.key?(delta["object"])

          cls = OBJECTS_TABLE[delta["object"]]
          if EXPANDED_OBJECTS_TABLE.key?(delta["object"]) && expanded_view
            cls = EXPANDED_OBJECTS_TABLE[delta["object"]]
          end

          obj = cls.new(api)

          case delta["event"]
          when "create", "modify"
            obj.inflate(delta["attributes"])
            obj.cursor = delta["cursor"]
            yield delta["event"], obj
          when "delete"
            obj.id = delta["id"]
            obj.cursor = delta["cursor"]
            yield delta["event"], obj
          end
        end

        http = EventMachine::HttpRequest.new(path, connect_timeout: 0, inactivity_timeout: timeout).get(keepalive: true)

        # set a callback on the HTTP stream that parses incoming chunks as they come in
        http.stream do |chunk|
          parser << chunk
        end

        http.errback do
          raise UnexpectedResponse, http.error
        end
      end
    end
  end
end
