# frozen_string_literal: true

require "spec_helper"

describe Nylas::SearchCollection do
  let(:api) { FakeAPI.new }

  describe "#count" do
    it "Returns an enumerable for a single page of results, filtered by `offset` and `limit` and `where`" do
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection/search",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return([{ id: "1234" }])

      collection = described_class.new(model: FullModel, api: api)

      expect(collection.count).to be 1
    end
  end
end
