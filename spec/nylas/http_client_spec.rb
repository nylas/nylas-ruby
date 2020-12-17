# frozen_string_literal: true

require "spec_helper"
require 'yajl'

describe Nylas::HttpClient do
  let(:full_json) do
    '{"account_id":"1234","bcc":[],"body":"","cc":[],"date":1607313827,"events":[],"files":[],"folder":{"display_name":"Deleted Messages","id":"1234","name":"trash"},"from":[{"email":"hello@nylas.com","name":"Book Updates"}],"id":"1234","object":"message","reply_to":[],"snippet":"\u26a1\ufe0f Some text \ud83d","starred":false,"subject":"Updates","thread_id":"1234","to":[{"email":"hello@nylas.com","name":"Hello Nylas"}],"unread":false}'
  end
  let(:api) { FakeAPI.new }

  describe "#parse_response" do
    it "deserializes JSON with unicode characters" do
      nylas = Nylas::HttpClient.new(app_id: 'id', app_secret: 'secret', access_token: 'token')

      response = nylas.parse_response(full_json)

      expect(response).not_to be_a_kind_of(String)
    end

    it "raises if the JSON is unable to be deserialized" do
      nylas = Nylas::HttpClient.new(app_id: 'id', app_secret: 'secret', access_token: 'token')

      expect {
        nylas.parse_response("{{")
      }.to raise_error(Yajl::ParseError)

    end
  end

end
