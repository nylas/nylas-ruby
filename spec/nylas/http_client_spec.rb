# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

describe Nylas::HttpClient do
  let(:full_json) do
    '{"snippet":"\u26a1\ufe0f Some text \ud83d","starred":false,"subject":"Updates"}'
  end

  let(:headers) do
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Authorization" => "Basic dG9rZW46",
      "Content-Types" => "application/json",
      "Host" => "api.nylas.com",
      "User-Agent" => "Nylas Ruby SDK 4.6.2 - 2.7.0",
      "X-Nylas-Api-Wrapper" => "ruby",
      "X-Nylas-Client-Id" => "id"
    }
  end

  describe "#parse_response" do
    it "deserializes JSON with unicode characters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      response = nylas.parse_response(full_json)
      expect(response).not_to be_a_kind_of(String)
    end

    it "raises if the JSON is unable to be deserialized" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      expect { nylas.parse_response("{{") }.to raise_error(Nylas::JsonParseError)
    end
  end

  describe "#execute handles content types" do
    it "parses JSON when given content-type == application/json" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234")
        .with(headers: headers)
        .to_return(status: 200, body: full_json, headers: { "Content-Type" => "Application/Json" })

      response = nylas.execute(method: :get, path: "/contacts/1234")
      expect(response).to be_a_kind_of(Hash)
    end

    it "skips parsing when content-type is not JSON" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234/picture")
        .with(headers: headers)
        .to_return(status: 200, body: "some values", headers: { "Content-Type" => "image/jpeg" })

      response = nylas.execute(method: :get, path: "/contacts/1234/picture")
      expect(response).to eql "some values"
    end
  end
end
