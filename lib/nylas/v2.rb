require_relative 'v2/model'
require_relative 'v2/contact'
module Nylas
  module V2
    # An ActiveModel and ActiveResource compliant version of the Nylas V2 SDK. Exposes collections of
    # resources for each endpoint.
    class SDK
      attr_accessor :client
      # @param client [Nylas::HttpClient] Used to send and retrieve data to the API
      def initialize(client: )
        self.client = client
      end

      def contacts
        [Nylas::V2::Contact.new(id: 1)]
      end
    end
  end
end
