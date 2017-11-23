require_relative 'v2/model'
require_relative 'v2/contact'
module Nylas
  module V2
    class SDK
      def initialize(app_id: , app_secret:, auth_token: )
      end

      def contacts
        [Nylas::V2::Contact.new(id: 1)]
      end
    end
  end
end
