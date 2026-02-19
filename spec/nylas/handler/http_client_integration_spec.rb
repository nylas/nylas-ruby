# frozen_string_literal: true

require "webmock/rspec"
require "tempfile"

class TestHttpClientIntegration
  include Nylas::HttpClient
end

describe Nylas::HttpClient do
  subject(:http_client) do
    http_client = TestHttpClientIntegration.new
    allow(http_client).to receive(:api_uri).and_return("https://test.api.nylas.com")

    http_client
  end

  describe "Integration Tests - file upload functionality" do
    it "correctly identifies file uploads in payload" do
      # Create a temporary file for testing
      temp_file = Tempfile.new("test")
      temp_file.write("test content")
      temp_file.rewind

      payload = {
        "message" => "test message",
        "file" => temp_file
      }

      expect(http_client.send(:file_upload?, payload)).to be true

      temp_file.close
      temp_file.unlink
    end

    it "returns false for non-file payloads" do
      payload = {
        "message" => "test message",
        "data" => "some data"
      }

      expect(http_client.send(:file_upload?, payload)).to be false
    end

    it "handles multipart requests correctly using Net::HTTP::Post::Multipart (issue #538)" do
      temp_file = Tempfile.new("test")
      temp_file.write("test content")
      temp_file.rewind

      payload = {
        "multipart" => true,
        "message" => "test message",
        "file" => temp_file
      }

      request_params = {
        method: :post,
        path: "https://test.api.nylas.com/upload",
        timeout: 30,
        payload: payload
      }

      stub_request(:post, "https://test.api.nylas.com/upload")
        .with(headers: { "Content-Type" => %r{multipart/form-data} })
        .to_return(status: 200, body: '{"success": true}', headers: { "Content-Type" => "application/json" })

      response = http_client.send(:execute, **request_params)
      expect(response[:success]).to be true

      expect(WebMock).to have_requested(:post, "https://test.api.nylas.com/upload")
        .with(headers: { "Content-Type" => %r{multipart/form-data} })

      temp_file.close
      temp_file.unlink
    end
  end

  describe "Integration Tests - backwards compatibility" do
    it "maintains the same response format as rest-client" do
      response_json = { "data" => { "id" => "123", "name" => "test" } }

      mock_response = instance_double("HTTParty::Response",
                                      body: response_json.to_json,
                                      headers: { "content-type" => "application/json" },
                                      code: 200)

      allow(HTTParty).to receive(:get).and_return(mock_response)

      request_params = {
        method: :get,
        path: "https://test.api.nylas.com/test",
        timeout: 30
      }

      response = http_client.send(:execute, **request_params)

      # Verify response structure matches expected format
      expect(response).to have_key(:data)
      expect(response).to have_key(:headers)
      expect(response[:data][:id]).to eq("123")
      expect(response[:data][:name]).to eq("test")
      expect(response[:headers]).to eq(mock_response.headers)
    end
  end
end
