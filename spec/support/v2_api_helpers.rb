require_relative '../../tests/credentials'
module Nylas
  module V2
    module SpecHelpers
      def config
        OpenStruct.new(test_app_id: TestCredentials::APP_ID,
                       test_app_secret: TestCredentials::APP_SECRET,
                       test_auth_token: TestCredentials::AUTH_TOKEN,)
      end

      def v2_sdk
        @v2_sdk ||= Nylas.sdk(version: "2", app_id: config.test_app_id,
                              app_secret: config.test_app_secret,
                              auth_token: config.test_auth_token)
      end

      def fixtures
        @fixtures ||= TestFixtures.new
      end
    end

    class TestFixtures
      def contacts_page_one
        [{ id: "1" }]
      end
    end
  end
end
