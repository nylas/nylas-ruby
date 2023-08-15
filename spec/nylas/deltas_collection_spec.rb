# frozen_string_literal: true

require "spec_helper"

describe Nylas::DeltasCollection do
  # Find a set of delta objects.
  describe "#find_each" do
    # Allow the search to iterate until responses are empty.
    it "supports iterating until the responses are empty" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          path: "/delta",
          method: :get,
          query: { cursor: "1", limit: 100, offset: 0 },
          headers: {}
        ).and_return(deltas: [{ object: "draft" }], cursor_start: "1", cursor_end: "2")
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          path: "/delta",
          method: :get,
          query: { cursor: "2", limit: 100, offset: 0 },
          headers: {}
        ).and_return(deltas: [{ object: "message" }], cursor_start: "2", cursor_end: "3")
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          path: "/delta",
          method: :get,
          query: { cursor: "3", limit: 100, offset: 0 },
          headers: {}
        ).and_return(deltas: [], cursor_start: "3", cursor_end: "4")

      deltas = described_class.new(api: api).since("1")
      all_deltas = deltas.find_each.map(&:to_h)

      expect(all_deltas.count).to be 2
      expect(all_deltas[0]).to include(object: "draft")
      expect(all_deltas[1]).to include(object: "message")
    end
  end

  # Retrieve the latest results from the latest_cursor endpoint.
  describe "#latest" do
    it "retrieves the results for the cursor that comes from the latest_cursor end point" do
      api = instance_double(Nylas::API)
      allow(api).to receive(:execute)
        .with(path: "/delta/latest_cursor", method: :post)
        .and_return(cursor: "4")

      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          path: "/delta",
          method: :get,
          query: { cursor: "4", limit: 100, offset: 0 },
          headers: {}
        ).and_return(deltas: [], cursor_start: "4", cursor_end: "5")

      deltas = described_class.new(api: api).latest
      expect(deltas).to be_empty
      expect(deltas.cursor_start).to eql "4"
      expect(deltas.cursor_end).to eql "5"
    end
  end
end
