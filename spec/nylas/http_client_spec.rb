# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

describe Nylas::HttpClient do
  let(:full_json) do
    '{"snippet":"\u26a1\ufe0f Some text \ud83d","starred":false,"subject":"Updates"}'
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
        .to_return(status: 200, body: full_json, headers: { "Content-Type" => "Application/Json" })

      response = nylas.execute(method: :get, path: "/contacts/1234")
      expect(response).to be_a_kind_of(Hash)
    end

    it "skips parsing when content-type is not JSON" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234/picture")
        .to_return(status: 200, body: "some values", headers: { "Content-Type" => "image/jpeg" })

      response = nylas.execute(method: :get, path: "/contacts/1234/picture")
      expect(response).to eql "some values"
    end
  end

  describe "#execute" do
    it "includes Nylas API Version in headers" do
      supported_api_version = "2.2"
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      allow(RestClient::Request).to receive(:execute)

      nylas.execute(method: :get, path: "/contacts/1234/picture")

      expect(RestClient::Request).to have_received(:execute).with(
        headers: hash_including("Nylas-API-Version" => supported_api_version),
        method: :get,
        payload: nil,
        timeout: 230,
        url: "https://token:@api.nylas.com/contacts/1234/picture"
      )
    end
  end

  describe "HTTP errors" do
    http_codes_errors = {
      400 => Nylas::InvalidRequest,
      401 => Nylas::UnauthorizedRequest,
      402 => Nylas::MessageRejected,
      403 => Nylas::AccessDenied,
      404 => Nylas::ResourceNotFound,
      405 => Nylas::MethodNotAllowed,
      410 => Nylas::ResourceRemoved,
      418 => Nylas::TeapotError,
      422 => Nylas::MailProviderError,
      429 => Nylas::SendingQuotaExceeded,
      500 => Nylas::InternalError,
      501 => Nylas::EndpointNotYetImplemented,
      502 => Nylas::BadGateway,
      503 => Nylas::ServiceUnavailable,
      504 => Nylas::RequestTimedOut
    }

    http_codes_errors.each do |code, error|
      it "should return #{error} given #{code} status code when no content-type present" do
        error_json = {
          "message": "Invalid datetime value z for start_time",
          "type": "invalid_request_error"
        }.to_json

        nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
        stub_request(:get, "https://api.nylas.com/contacts")
          .to_return(status: code, body: error_json)

        expect { nylas.execute(method: :get, path: "/contacts") }.to raise_error(error)
      end

      it "should return #{error} given #{code} status code when content-type is json" do
        error_json = {
          "message": "Invalid datetime value z for start_time",
          "type": "invalid_request_error"
        }.to_json

        nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
        stub_request(:get, "https://api.nylas.com/contacts")
          .to_return(status: code, body: error_json, headers: { "Content-Type" => "Application/Json" })

        expect { nylas.execute(method: :get, path: "/contacts") }.to raise_error(error)
      end
    end
  end

  describe "building URL with query params" do
    url = "https://token:@api.nylas.com"
    path = "/contacts/1234/picture"

    it "no query parameters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: {})

      expect(CGI.unescape(request[:url])).to eql(url + path)
    end

    it "one query parameter" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: { param: "value" })

      expected_params = "?param=value"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    it "multiple query parameters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      params = { id: "1234", limit: 100, offset: 0, view: "count" }
      request = nylas.build_request(method: :get, path: path, query: params)

      expected_params = "?id=1234&limit=100&offset=0&view=count"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    it "array of query parameter values" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: { metadata_key: %w[key1 key2 key3] })

      expected_params = "?metadata_key=key1&metadata_key=key2&metadata_key=key3"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    it "setting metadata_pair query param (set hash of key-value pairs)" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      metadata_pair = { key1: "value1", key2: "value2", key3: "value3" }
      request = nylas.build_request(method: :get, path: path, query: { metadata_pair: metadata_pair })

      expected_params = "?metadata_pair=key1:value1&metadata_pair=key2:value2&metadata_pair=key3:value3"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end
  end
end
