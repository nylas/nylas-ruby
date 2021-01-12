# frozen_string_literal: true

require "spec_helper"
require "yajl"
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
      expect { nylas.parse_response("{{") }.to raise_error(Yajl::ParseError)
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
          .with(headers: headers)
          .to_return(status: code, body: full_json)

        expect { nylas.execute(method: :get, path: "/contacts") }.to raise_error(error)
      end
    end
  end
end
