require 'lock_jar'
LockJar.load(resolve: true)

java_import 'com.tobedevoured.json.SimpleStream'
java_import 'org.json.simple.JSONArray'
java_import 'org.json.simple.JSONObject'
java_import 'java.util.HashMap'
java_import 'java.util.List'

module Nylas
  module StreamHandlers
    class SimpleStream
      UnexpectedResponse = Class.new(::StandardError)

      def transform_to_ruby(data)
        case data
        when Array, List, JSONArray
          transformed_data = data.to_a.map do |v|
            transform_to_ruby(v)
          end
        when JSONObject, HashMap
          transformed_data = Naether::Java.convert_to_ruby_hash(data)
          transformed_data.each do |k, v|
            transformed_data[k] = transform_to_ruby(v)
          end
        when Hash
          transformed_data = data
          transformed_data.each do |k, v|
            transformed_data[k] = transform_to_ruby(v)
          end
        else
          transformed_data = data
        end

        transformed_data
      end

      def stream_activity(path, timeout, &callback)
        parser = ::SimpleStream.new

        parser_callback = proc do |data|
          callback.call(transform_to_ruby(data))
        end

        parser.setCallback(parser_callback)

        begin
          parser.streamFromUrl(path, timeout)
        rescue => ex
          fail UnexpectedResponse.new(ex)
        end
      end
    end
  end
end
