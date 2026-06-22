# frozen_string_literal: true

describe Nylas::Lists do
  let(:lists) { described_class.new(client) }
  let(:response) do
    [{
      id: "list-123",
      name: "Blocked domains",
      description: "Domains we have identified as sending unwanted mail.",
      type: "domain",
      items_count: 0,
      application_id: "app-123",
      organization_id: "org-123",
      created_at: 1_234_567_890,
      updated_at: 1_234_567_890
    }, "mock_request_id", {}]
  end

  describe Nylas::ListType do
    it "defines the public list type values" do
      expect(described_class::DOMAIN).to eq("domain")
      expect(described_class::TLD).to eq("tld")
      expect(described_class::ADDRESS).to eq("address")
    end
  end

  describe "#create" do
    it "calls the post method with the correct path and public request body" do
      request_body = {
        name: "Blocked domains",
        description: "Domains we have identified as sending unwanted mail.",
        type: Nylas::ListType::DOMAIN
      }
      path = "#{api_uri}/v3/lists"
      allow(lists).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      lists_response = lists.create(request_body: request_body)

      expect(lists_response).to eq(response)
    end
  end
end
