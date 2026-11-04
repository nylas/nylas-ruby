# frozen_string_literal: true

require "webmock/rspec"

describe Nylas::Events do
  let(:events) { described_class.new(client) }
  let(:path) { "#{api_uri}/v3/grants/grant-123/events/batch" }
  let(:query_params) do
    {
      calendar_id: "primary",
      notify_participants: false,
      grant_email: "user@example.com",
      tentative_as_busy: true,
      select: "id,title,when"
    }
  end
  let(:request_body) do
    {
      operations: [
        { method: "create",
          body: { title: "Standup", when: { start_time: 1798794000, end_time: 1798795800 } } },
        { method: "update", event_id: "event-1", body: { title: "Renamed" } },
        { method: "delete", event_id: "event-2" }
      ]
    }
  end

  describe "#batch" do
    it "sends snake_case JSON and all query parameters and returns ordered results without a cursor" do
      results = [
        { status: 200,
          data: { id: "created-event", title: "Standup", when: request_body[:operations][0][:body][:when] } },
        { status: 200, data: { id: "event-1", title: "Renamed" } },
        { status: 200 }
      ]
      request = stub_request(:post, path)
                .with(
                  query: query_params,
                  body: request_body.to_json,
                  headers: { "Content-Type" => "application/json" }
                )
                .to_return(
                  status: 200,
                  body: { data: results, request_id: "batch-request" }.to_json,
                  headers: { "Content-Type" => "application/json", "X-Batch-Header" => "test-value" }
                )

      data, request_id, headers = events.batch(identifier: "grant-123", query_params: query_params,
                                               request_body: request_body)

      expect(data).to eq(results)
      expect(data.last).not_to have_key(:data)
      expect(request_id).to eq("batch-request")
      expect(headers["x-batch-header"]).to eq("test-value")
      expect(request).to have_been_requested.once
    end

    it "leaves optional query parameters unset to preserve server defaults" do
      request = stub_request(:post, path)
                .with(query: { calendar_id: "primary" }, body: request_body.to_json)
                .to_return(
                  status: 200,
                  body: { data: [{ status: 200 }], request_id: "batch-request" }.to_json,
                  headers: { "Content-Type" => "application/json" }
                )

      events.batch(identifier: "grant-123", query_params: { calendar_id: "primary" },
                   request_body: request_body)

      expect(request).to have_been_requested.once
    end

    it "encodes the grant identifier as a single URL path segment" do
      request = stub_request(:post, "#{api_uri}/v3/grants/grant%2Ffixture%3Fquery%23fragment/events/batch")
                .with(query: query_params, body: request_body.to_json)
                .to_return(status: 200, body: { data: [], request_id: "batch-request" }.to_json,
                           headers: { "Content-Type" => "application/json" })

      events.batch(identifier: "grant/fixture?query#fragment", query_params: query_params,
                   request_body: request_body)

      expect(request).to have_been_requested.once
    end

    it "rejects blank, dot-segment, and non-string grant identifiers before sending any HTTP request" do
      [nil, true, false, 123, {}, [], "", "   ", "\t\n", ".", "..", " . ", "\t..\n"].each do |identifier|
        expect do
          events.batch(identifier: identifier, query_params: query_params, request_body: request_body)
        end.to raise_error(ArgumentError, "Invalid grant identifier.")
      end

      expect(WebMock).not_to have_requested(:any, /.*/)
    end

    it "returns mixed 207 results with provider errors and retry metadata without retrying" do
      results = [
        { status: 200, data: { id: "created-event", title: "Standup" } },
        {
          status: 429,
          error: { type: "provider_error", message: "Try later", provider_error: { code: "throttled" } },
          retry_after: 0
        },
        {
          status: 503,
          error: { type: "provider_error", message: "Event synchronization failed" },
          retry_after: 3.5,
          provider_event_created: true
        }
      ]
      request = stub_request(:post, path)
                .with(query: query_params, body: request_body.to_json)
                .to_return(status: 207, body: { data: results, request_id: "partial-request" }.to_json,
                           headers: { "Content-Type" => "application/json" })

      data, request_id = events.batch(identifier: "grant-123", query_params: query_params,
                                      request_body: request_body)

      expect(data).to eq(results)
      expect(data[1][:retry_after]).to eq(0)
      expect(data[2][:provider_event_created]).to be(true)
      expect(request_id).to eq("partial-request")
      expect(request).to have_been_requested.once
    end

    it "returns 207 normally when every operation failed" do
      results = request_body[:operations].map do
        { status: 404, error: { type: "not_found_error", message: "Event not found" } }
      end
      stub_request(:post, path)
        .with(query: query_params, body: request_body.to_json)
        .to_return(status: 207, body: { data: results, request_id: "failed-items-request" }.to_json,
                   headers: { "Content-Type" => "application/json" })

      data, request_id = events.batch(identifier: "grant-123", query_params: query_params,
                                      request_body: request_body)

      expect(data).to eq(results)
      expect(request_id).to eq("failed-items-request")
    end

    it "raises the normal API error for an invalid whole request" do
      stub_request(:post, path)
        .with(query: query_params, body: request_body.to_json)
        .to_return(
          status: 400,
          body: {
            request_id: "invalid-request",
            error: { type: "invalid_request_error", message: "Invalid batch operations" }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect do
        events.batch(identifier: "grant-123", query_params: query_params, request_body: request_body)
      end.to raise_error(Nylas::NylasApiError) { |error|
        expect(error.status_code).to eq(400)
        expect(error.request_id).to eq("invalid-request")
        expect(error.type).to eq("invalid_request_error")
        expect(error.message).to eq("Invalid batch operations")
      }
    end
  end
end
