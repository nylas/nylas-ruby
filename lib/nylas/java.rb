require 'lock_jar'
require 'http'
LockJar.load

java_import 'com.tobedevoured.json.SimpleStream'

module Nylas
  module Java

    def stream_activity(path, timeout, &callback)
      parser = SimpleStream.new
      parser.setCallback(callback)

      begin
        HTTP.persistent(path) do |http|
          response = http.get(path).body
          while chunk = response.readpartial
            parser.stream(chunk)
          end
        end
      rescue => ex
        fail UnexpectedResponse.new ex
      end
    end
  end
end
