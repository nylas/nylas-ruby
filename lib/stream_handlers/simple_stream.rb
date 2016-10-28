require 'sjs/simple_stream'

module Nylas
  module StreamHandlers
    class SimpleStream
      UnexpectedResponse = Class.new(::StandardError)

      def stream_activity(path, timeout, &callback)
        parser = ::Sjs::SimpleStream.new
        begin
          parser.streamFromUrl(path, timeout, &callback)
        rescue => ex
          fail UnexpectedResponse.new(ex)
        end
      end
    end
  end
end
