# frozen_string_literal: true

class TestHttpClient
  include Nylas::HttpClient
end

describe Nylas::HttpClient do
  subject(:http_client) { TestHttpClient.new }

  describe "#default_headers" do
    before do
      stub_const("Nylas::VERSION", "1.0.0")
      stub_const("RUBY_VERSION", "5.0.0")
    end

    it "returns the default headers" do
      expect(http_client.send(:default_headers)).to eq(
        "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
        "X-Nylas-API-Wrapper" => "ruby"
      )
    end
  end

  describe "#parse_response" do
    it "returns the response if it's already enumerable" do
      response = { "foo" => "bar" }

      expect(http_client.send(:parse_response, response)).to eq(response)
    end

    it "parses the response if it's not enumerable" do
      response = '{"foo":"bar"}'

      expect(http_client.send(:parse_response, response)).to eq(foo: "bar")
    end

    it "raises an error if the response is not valid JSON" do
      response = "foo"

      expect { http_client.send(:parse_response, response) }.to raise_error(Nylas::JsonParseError)
    end
  end

  describe "#build_request" do
    before do
      stub_const("Nylas::VERSION", "1.0.0")
      stub_const("RUBY_VERSION", "5.0.0")
    end

    it "returns the correct request with default values" do
      request = http_client.send(:build_request, method: :get, path: "https://test.api.nylas.com/foo",
                                                 api_key: "fake-key")

      expect(request[:method]).to eq(:get)
      expect(request[:url]).to eq("https://test.api.nylas.com/foo")
      expect(request[:payload]).to be_nil
      expect(request[:headers]).to eq(
        "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
        "X-Nylas-API-Wrapper" => "ruby",
        "Authorization" => "Bearer fake-key"
      )
    end

    it "returns the correct request with custom headers" do
      extra_headers = {
        "X-Custom-Header" => "custom-value",
        "X-Custom-Header-2" => "custom-value-2"
      }
      request = http_client.send(:build_request, method: :get, path: "https://test.api.nylas.com/foo",
                                                 headers: extra_headers, api_key: "fake-key")

      expect(request[:method]).to eq(:get)
      expect(request[:url]).to eq("https://test.api.nylas.com/foo")
      expect(request[:payload]).to be_nil
      expect(request[:headers]).to eq(
        "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
        "X-Nylas-API-Wrapper" => "ruby",
        "Authorization" => "Bearer fake-key",
        "X-Custom-Header" => "custom-value",
        "X-Custom-Header-2" => "custom-value-2"
      )
    end

    it "returns the correct request with custom timeout" do
      request = http_client.send(:build_request, method: :get, path: "https://test.api.nylas.com/foo",
                                                 api_key: "fake-key", timeout: 30)

      expect(request[:method]).to eq(:get)
      expect(request[:url]).to eq("https://test.api.nylas.com/foo")
      expect(request[:payload]).to be_nil
      expect(request[:headers]).to eq(
        "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
        "X-Nylas-API-Wrapper" => "ruby",
        "Authorization" => "Bearer fake-key"
      )
      expect(request[:timeout]).to eq(30)
    end

    it "returns the correct request with query params" do
      query = { query: "bar" }
      request = http_client.send(:build_request, method: :get, path: "https://test.api.nylas.com/foo",
                                                 query: query, api_key: "fake-key")

      expect(request[:method]).to eq(:get)
      expect(request[:url]).to eq("https://test.api.nylas.com/foo?query=bar")
      expect(request[:payload]).to be_nil
      expect(request[:headers]).to eq(
        "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
        "X-Nylas-API-Wrapper" => "ruby",
        "Authorization" => "Bearer fake-key"
      )
    end

    context "when building request with a payload" do
      it "returns the correct request with a json payload" do
        payload = { foo: "bar" }
        request = http_client.send(:build_request, method: :post, path: "https://test.api.nylas.com/foo",
                                                   payload: payload, api_key: "fake-key")

        expect(request[:method]).to eq(:post)
        expect(request[:url]).to eq("https://test.api.nylas.com/foo")
        expect(request[:payload]).to eq('{"foo":"bar"}')
        expect(request[:headers]).to eq(
          "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
          "X-Nylas-API-Wrapper" => "ruby",
          "Authorization" => "Bearer fake-key",
          "Content-type" => "application/json"
        )
      end

      it "returns the correct request with a multipart flag" do
        payload = { "multipart" => true }
        request = http_client.send(:build_request, method: :post, path: "https://test.api.nylas.com/foo",
                                                   payload: payload, api_key: "fake-key")

        expect(request[:method]).to eq(:post)
        expect(request[:url]).to eq("https://test.api.nylas.com/foo")
        expect(request[:payload]).to eq({})
        expect(request[:headers]).to eq(
          "User-Agent" => "Nylas Ruby SDK 1.0.0 - 5.0.0",
          "X-Nylas-API-Wrapper" => "ruby",
          "Authorization" => "Bearer fake-key"
        )
      end
    end
  end

  describe "#execute" do
    let(:mock_request) { double(:request, redirection_history: nil) }

    it "returns the response" do
      response_json = {
        "foo" => "bar"
      }
      request_params = { method: :get, path: "https://test.api.nylas.com/foo", timeout: 30 }
      mock_http_res = double(:response, to_hash: {}, code: 200,
                                        headers: { content_type: "application/json" })
      mock_response = RestClient::Response.create(response_json.to_json, mock_http_res, mock_request)
      allow(RestClient::Request).to receive(:execute).and_return(mock_response)

      response = http_client.send(:execute, **request_params)

      expect(response.body).to eq(response_json.to_json)
    end
  end
end
