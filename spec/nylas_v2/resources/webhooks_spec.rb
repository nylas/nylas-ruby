# frozen_string_literal: true

describe NylasV2::Webhooks do
  let(:webhooks) { described_class.new(client) }
  let(:response) do
    {
      id: "UMWjAjMeWQ4D8gYF2moonK4486",
      description: "Production webhook destination",
      trigger_types: ["calendar.created"],
      webhook_url: "https://example.com/webhooks",
      status: "active",
      notification_email_addresses: %w[jane@example.com joe@example.com],
      status_updated_at: 1234567890,
      created_at: 1234567890,
      updated_at: 1234567890
    }
  end

  describe "#list" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/webhooks"
      list_response = [[response[0]], response[1]]
      allow(webhooks).to receive(:get)
        .with(path: path)
        .and_return(list_response)

      webhooks_response = webhooks.list

      expect(webhooks_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      webhook_id = "webhook-123"
      path = "#{api_uri}/v3/webhooks/#{webhook_id}"
      allow(webhooks).to receive(:get)
        .with(path: path)
        .and_return(response)

      webhook_response = webhooks.find(webhook_id: webhook_id)

      expect(webhook_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        trigger_types: ["calendar.created"],
        webhook_url: "https://example.com/webhooks",
        description: "Production webhook destination",
        notification_email_addresses: ["jane@test.com"]
      }
      path = "#{api_uri}/v3/webhooks"
      allow(webhooks).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      webhook_response = webhooks.create(request_body: request_body)

      expect(webhook_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      webhook_id = "webhook-123"
      request_body = {
        trigger_types: ["calendar.created"],
        webhook_url: "https://example.com/webhooks",
        description: "Production webhook destination",
        notification_email_addresses: ["jane@test.com"]
      }
      path = "#{api_uri}/v3/webhooks/#{webhook_id}"
      allow(webhooks).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      webhook_response = webhooks.update(webhook_id: webhook_id, request_body: request_body)

      expect(webhook_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      webhook_id = "webhook-123"
      path = "#{api_uri}/v3/webhooks/#{webhook_id}"
      allow(webhooks).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      webhook_response = webhooks.destroy(webhook_id: webhook_id)

      expect(webhook_response).to eq([true, "mock_request_id"])
    end
  end

  describe "#rotate_secret" do
    it "calls the put method with the correct parameters" do
      webhook_id = "webhook-123"
      path = "#{api_uri}/v3/webhooks/rotate-secret/#{webhook_id}"

      allow(webhooks).to receive(:post)
        .with(path: path, request_body: {})

      webhooks.rotate_secret(webhook_id: webhook_id)
    end
  end

  describe "#ip_addresses" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/webhooks/ip-addresses"
      allow(webhooks).to receive(:get)
        .with(path: path)
        .and_return(response)

      webhook_response = webhooks.ip_addresses

      expect(webhook_response).to eq(response)
    end
  end

  describe "#extract_challenge_parameter" do
    it "returns the challenge parameter" do
      url = "https://example.com?challenge=1234"
      expect(described_class.extract_challenge_parameter(url)).to eq("1234")
    end

    it "raises an error if the URL does not contain a challenge parameter" do
      url = "https://example.com"
      expect { described_class.extract_challenge_parameter(url) }
        .to raise_error(RuntimeError, "Invalid URL or no challenge parameter found.")
    end
  end
end
