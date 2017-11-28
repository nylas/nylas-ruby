require_relative '../../tests/credentials'
module Nylas
  module V2
    module SpecHelpers
      def config
        OpenStruct.new(test_app_id: TestCredentials::APP_ID,
                       test_app_secret: TestCredentials::APP_SECRET,
                       test_access_token: TestCredentials::ACCESS_TOKEN,)
      end

      def v2_sdk
        @v2_sdk ||= Nylas::V2::SDK.new(client: fake_client)
      end


      def fixtures
        @fixtures ||= TestFixtures.new
      end

      def fake_client
        @fake_client ||= FakeClient.new(fixtures: fixtures)
      end
    end

    class FakeClient
      attr_accessor :fixtures
      def initialize(fixtures: )
        self.fixtures = fixtures
      end
    end

    class TestFixtures
      def contacts_page_one
        [{ id: "1" }]
      end
    end
  end
end
