# frozen_string_literal: true

require "spec_helper"
require "yajl"

describe Nylas::HttpClient do
  let(:full_json) do
    '{"snippet":"\u26a1\ufe0f Some text \ud83d","starred":false,"subject":"Updates"}'
  end
  let(:api) { FakeAPI.new }

  describe "#parse_response" do
    it "deserializes JSON with unicode characters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      response = nylas.parse_response(full_json)
      expect(response).not_to be_a_kind_of(String)
    end

    it "raises if the JSON is unable to be deserialized" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      expect { nylas.parse_response("{{") }.to raise_error(Yajl::ParseError)
    end
  end

end
