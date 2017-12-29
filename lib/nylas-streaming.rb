require "yajl"
require "em-http"
require "nylas"

module Nylas
  # Provides methods to work with the Nylas Streaming Deltas API
  # @see https://docs.nylas.com/reference#streaming-delta-updates
  module Streaming
    # @see Nylas::Streaming::DeltaStream#initialize
    def self.deltas(**kwargs, &callback)
      DeltaStream.new(**kwargs).stream(&callback)
    end

    # A live stream of deltas that stays open until explicitely closed
    class DeltaStream
      attr_accessor :cursor, :api, :exclude_types, :include_types, :expanded,
                    :connect_timeout, :inactivity_timeout

      # @param cursor [String] Cursor to start listening for changes on
      # @param api [Nylas::API]
      # @param expanded [Boolean] Expands threads and messages
      # @param exclude_types [Array<String>] List of Object types *not* to include in the stream
      # @param include_types [Array<String>] List of Object types to exclusively include in the stream
      # @param connect_timeout [Integer] How long to wait before timing out on attempted connection
      # @param inactivity_timeout [Integer] How long to wait before timing out on inactivity
      # rubocop:disable Metrics/ParameterLists
      def initialize(cursor:, api:, exclude_types: [], include_types: [], expanded: false, connect_timeout: 0,
                     inactivity_timeout: 0)
        self.cursor = cursor
        self.api = api
        self.exclude_types = exclude_types
        self.include_types = include_types
        self.expanded = expanded
        self.connect_timeout = connect_timeout
        self.inactivity_timeout = inactivity_timeout
      end
      # rubocop:enable Metrics/ParameterLists

      def stream
        parser.on_parse_complete = lambda do |data|
          begin
            yield(Types.registry[:delta].cast(data.merge(api: api)))
          rescue Nylas::Error => e
            Nylas::Logging.logger.error(e)
            raise e
          end
        end

        listener.stream { |chunk| parser << chunk }
      end

      def url
        "#{api.client.url_for_path('/delta/streaming')}?#{query}"
      end

      def query
        query = ["cursor=#{cursor}"]
        query << "view=expanded" if expanded
        query << "include_types=#{include_types.join(',')}" unless include_types.empty?
        query << "exclude_types=#{exclude_types.join(',')}" unless exclude_types.empty?
        query.join("&")
      end

      def listener
        @listener ||= EventMachine::HttpRequest.new(url, connect_timeout: connect_timeout,
                                                         inactivity_timeout: inactivity_timeout).get
      end

      def http_error_handler(client)
        raise Nylas::Error, client.error
      end

      def parser
        return @parser if @parser
        @parser = Yajl::Parser.new(symbolize_keys: true)
        @parser
      end
    end
  end
end
