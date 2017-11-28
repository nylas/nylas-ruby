require_relative 'message'
module Nylas
  module V1
    class ExpandedMessage < Message
      # override inflate because expanded messages have some special parameters
      # like In-Reply-To and Message-Id.
      attr_reader :message_id
      attr_reader :in_reply_to
      attr_reader :references

      def self.collection_name
        'messages'
      end

      def inflate(json)
        super
        @message_id = json['headers']['Message-Id']
        @in_reply_to = json['headers']['In-Reply-To']
        @references = json['headers']['References']
      end
    end
  end
end
