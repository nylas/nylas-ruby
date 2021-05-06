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
      nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
      allow(RestClient::Request).to receive(:execute)

      nylas.execute(method: :get, path: "/contacts/1234/picture")

      expect(RestClient::Request).to have_received(:execute).with(
        headers: hash_including("Nylas-API-Version" => "2.2"),
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
      it "should return #{error} given #{code} status code" do
        nylas = described_class.new(app_id: "id", app_secret: "secret", access_token: "token")
        stub_request(:get, "https://api.nylas.com/contacts")
          .to_return(status: code, body: full_json, headers: { "Content-Type" => "Application/Json" })

        expect { nylas.execute(method: :get, path: "/contacts") }.to raise_error(error)
      end
    end
  end
end
