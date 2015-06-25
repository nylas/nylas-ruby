require 'restful_model'
require 'account'
require 'tag'
require 'message'
require 'draft'
require 'contact'
require 'file'
require 'calendar'
require 'event'
require 'yajl'
require 'em-http'
require 'ostruct'

# Rather than saying require 'thread', we need to explicitly force
# the thread model to load. Otherwise, we can't reference it below.
# Thread still refers to the built-in Thread type, and Inbox::Thread
# is undefined.
load "api_thread.rb"

module Inbox

  class Namespace < RestfulModel

    parameter :account_id
    parameter :name
    parameter :email_address
    parameter :provider

    def self.collection_name
      "n"
    end

    def threads
      @threads ||= RestfulModelCollection.new(Thread, @_api, @id)
    end

    def tags
      @tags ||= RestfulModelCollection.new(Tag, @_api, @id)
    end

    def messages
      @messages ||= RestfulModelCollection.new(Message, @_api, @id)
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, @id)
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, @_api, @id)
    end

    def contacts
      @contacts ||= RestfulModelCollection.new(Contact, @_api, @id)
    end

    def calendars
      @calendars ||= RestfulModelCollection.new(Calendar, @_api, @id)
    end

    def events
      @events ||= RestfulModelCollection.new(Event, @_api, @id)
    end

    def get_cursor(timestamp)
      # Get the cursor corresponding to a specific timestamp.
      path = @_api.url_for_path("/n/#{@namespace_id}/delta/generate_cursor")
      data = { :start => timestamp }

      cursor = nil

      RestClient.post(path, data.to_json, :content_type => :json) do |response,request,result|
        json = Inbox.interpret_response(result, response, {:expected_class => Object})
        cursor = json["cursor"]
      end

      cursor
    end

    OBJECTS_TABLE = {
      "account" => Inbox::Account,
      "calendar" => Inbox::Calendar,
      "draft" => Inbox::Draft,
      "thread" => Inbox::Thread,
      "contact" => Inbox::Contact,
      "event" => Inbox::Event,
      "file" => Inbox::File,
      "message" => Inbox::Message,
      "namespace" => Inbox::Namespace,
      "tag" => Inbox::Tag,
    }

    def _build_exclude_types(exclude_types)
      exclude_string = "&exclude_types="

      exclude_types.each do |value|
        count = 0
        if OBJECTS_TABLE.has_value?(value)
          param_name = OBJECTS_TABLE.key(value)
          exclude_string += "#{param_name},"
        end
      end

      exclude_string = exclude_string[0..-2]
    end

    def deltas(cursor, exclude_types=[])
      raise 'Please provide a block for receiving the delta objects' if !block_given?
      exclude_string = ""

      if exclude_types.any?
        exclude_string = _build_exclude_types(exclude_types)
      end

      # loop and yield deltas until we've come to the end.
      loop do
        path = @_api.url_for_path("/n/#{@namespace_id}/delta?cursor=#{cursor}#{exclude_string}")
        json = nil

        RestClient.get(path) do |response,request,result|
          json = Inbox.interpret_response(result, response, {:expected_class => Object})
        end

        start_cursor = json["cursor_start"]
        end_cursor = json["cursor_end"]

        json["deltas"].each do |delta|
          object = delta['object']
          if object == 'message'
              # Drafts are messages underneath
              object = delta['attributes']['object']
          end
          cls = OBJECTS_TABLE[object]
          obj = cls.new(@_api, @namespace_id)

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

    def delta_stream(cursor, exclude_types=[], timeout=0)
      raise 'Please provide a block for receiving the delta objects' if !block_given?

      exclude_string = ""

      if exclude_types.any?
        exclude_string = _build_exclude_types(exclude_types)
      end

      # loop and yield deltas indefinitely.
      path = @_api.url_for_path("/n/#{@namespace_id}/delta/streaming?cursor=#{cursor}#{exclude_string}")

      parser = Yajl::Parser.new(:symbolize_keys => false)
      parser.on_parse_complete = proc do |data|
        delta = Inbox.interpret_response(OpenStruct.new(:code => '200'), data, {:expected_class => Object, :result_parsed => true})

        cls = OBJECTS_TABLE[delta['object']]
        obj = cls.new(@_api, @namespace_id)

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

      EventMachine.run do
        http = EventMachine::HttpRequest.new(path, :connect_timeout => 0, :inactivity_timeout => timeout).get(:keepalive => true)
        http.stream do |chunk|
          parser << chunk
        end
        http.errback do
          raise UnexpectedResponse.new http.error
        end
      end
    end

  end
end
