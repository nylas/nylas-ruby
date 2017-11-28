module Nylas
  module V1
    class SDK
      def delta_stream(cursor, exclude_types=[], timeout=0, expanded_view=false, include_types=[])
        raise 'Please provide a block for receiving the delta objects' if !block_given?

        exclude_string = _build_types_filter_string(:exclude, exclude_types)
        include_string = _build_types_filter_string(:include, include_types)

        # loop and yield deltas indefinitely.
        path = self.url_for_path("/delta/streaming?exclude_folders=false&cursor=#{cursor}#{exclude_string}#{include_string}")
        if expanded_view
          path += '&view=expanded'
        end

        parser = Yajl::Parser.new(:symbolize_keys => false)
        parser.on_parse_complete = proc do |data|
          delta = Nylas.interpret_response(OpenStruct.new(:code => '200'), data, {:expected_class => Object, :result_parsed => true})

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

        http = EventMachine::HttpRequest.new(path, :connect_timeout => 0, :inactivity_timeout => timeout).get(:keepalive => true)

        # set a callback on the HTTP stream that parses incoming chunks as they come in
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
