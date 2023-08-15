# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

describe Nylas::HttpClient do
  let(:full_json) do
    '{"snippet":"\u26a1\ufe0f Some text \ud83d","starred":false,"subject":"Updates"}'
  end

  # Set how the HTTP client parses JSON responses from the API.
  describe "#parse_response" do
    # Set the HTTP client to deserialize JSON responses with unicode characters.
    it "deserializes JSON with unicode characters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      response = nylas.parse_response(full_json)
      expect(response).not_to be_a_kind_of(String)
    end

    # Raise an error if the JSON response cannot be deserialized.
    it "raises if the JSON is unable to be deserialized" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      expect { nylas.parse_response("{{") }.to raise_error(Nylas::JsonParseError)
    end
  end

  # Set how the HTTP client handles content types.
  describe "#execute handles content types" do
    # Set the HTTP client to parse JSON when the content-type is "application/json".
    it "parses JSON when given content-type == application/json" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234")
        .to_return(status: 200, body: full_json, headers: { "Content-Type" => "Application/Json" })

      response = nylas.execute(method: :get, path: "/contacts/1234")
      expect(response).to be_a_kind_of(Hash)
    end

    # Set the HTTP client to generate and throw an error when the content-type is "application/json",
    # but the response is not a JSON string.
    it "throws an error if content-type == application/json but response is not a json" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234")
        .to_return(status: 200, body: "abc", headers: { "Content-Type" => "Application/Json" })

      expect { nylas.execute(method: :get, path: "/contacts/1234") }.to raise_error(Nylas::JsonParseError)
    end

    # Set the HTTP client to generate and throw an API error when the content-type is "application/json",
    # but the response is not a JSON string.
    it "still throws an API error if content-type == application/json but response is not a json" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234")
        .to_return(status: 400, body: "abc", headers: { "Content-Type" => "Application/Json" })

      expect { nylas.execute(method: :get, path: "/contacts/1234") }.to raise_error(Nylas::InvalidRequest)
    end

    # Set the HTTP client to skip parsing the response when the content-type is not "application/json".
    it "skips parsing when content-type is not JSON" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/contacts/1234/picture")
        .to_return(status: 200, body: "some values", headers: { "Content-Type" => "image/jpeg" })

      response = nylas.execute(method: :get, path: "/contacts/1234/picture")
      expect(response).to eql "some values"
    end
  end

  describe "#execute" do
    # Include the Nylas API version in the HTTP client's headers.
    it "includes Nylas API Version in headers" do
      supported_api_version = "2.5"
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

    # Set the HTTP client's redirect method.
    it "handles redirect correctly" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")

      stub_request(:get, "https://api.nylas.com/oauth/authorize")
        .to_return(status: 302, body: "")

      response = nylas.execute(method: :get, path: "/oauth/authorize")
      expect(response).to eq("")
    end
  end

  # Set and generate HTTP errors.
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
      # Generate and throw an error based on the error type and error code when the content-type is
      # not set.
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

      # Generate and throw an error based on the error type and error code when the content-type is
      # "application/json".
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

    # Set the HTTP client's rate limit responses.
    it "extracts rate limit responses properly" do
      error_json = {
        "message": "Too many requests",
        "type": "invalid_request_error"
      }.to_json
      error_headers = {
        "X-RateLimit-Limit": "500",
        "X-RateLimit-Reset": "10"
      }

      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      stub_request(:get, "https://api.nylas.com/contacts")
        .to_return(status: 429, body: error_json, headers: error_headers)

      expect { nylas.execute(method: :get, path: "/contacts") }
        .to raise_error(an_instance_of(Nylas::SendingQuotaExceeded)
                         .and(having_attributes(
                                rate_limit: 500,
                                rate_limit_reset: 10
                              )))
    end
  end

  # Build the HTTP client's URL.
  describe "building URL with query params" do
    url = "https://token:@api.nylas.com"
    path = "/contacts/1234/picture"

    # Build the HTTP client's URL with no query params.
    it "no query parameters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: {})

      expect(CGI.unescape(request[:url])).to eql(url + path)
    end

    # Build the HTTP client's URL with one query param.
    it "one query parameter" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: { param: "value" })

      expected_params = "?param=value"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    # Build the HTTP client's URL with multiple query params.
    it "multiple query parameters" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      params = { id: "1234", limit: 100, offset: 0, view: "count" }
      request = nylas.build_request(method: :get, path: path, query: params)

      expected_params = "?id=1234&limit=100&offset=0&view=count"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    # Build the HTTP client's URL with an array of query param values.
    it "array of query parameter values" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      request = nylas.build_request(method: :get, path: path, query: { metadata_key: %w[key1 key2 key3] })

      expected_params = "?metadata_key=key1&metadata_key=key2&metadata_key=key3"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end

    # Set the metadata_pair query param.
    it "setting metadata_pair query param (set hash of key-value pairs)" do
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      metadata_pair = { key1: "value1", key2: "value2", key3: "value3" }
      request = nylas.build_request(method: :get, path: path, query: { metadata_pair: metadata_pair })

      expected_params = "?metadata_pair=key1:value1&metadata_pair=key2:value2&metadata_pair=key3:value3"
      expect(CGI.unescape(request[:url])).to eql(url + path + expected_params)
    end
  end
end
