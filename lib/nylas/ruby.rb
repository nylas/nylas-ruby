require 'yajl'
require 'em-http'

module Nylas
  module Ruby
    UnexpectedResponse = Class.new(::StandardError)

    def stream_activity(path, timeout, &callback)
      parser = Yajl::Parser.new(:symbolize_keys => false)
      parser.on_parse_complete = callback

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
