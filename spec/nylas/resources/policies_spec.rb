# frozen_string_literal: true

describe Nylas::Policies do
  let(:policies) { described_class.new(client) }
  let(:response) do
    [{
      id: "policy-123",
      name: "Agent default policy",
      application_id: "app-123",
      organization_id: "org-123",
      rules: ["rule-123"],
      limits: {
        limit_attachment_size_limit: 26_214_400,
        limit_attachment_count_limit: 25,
        limit_attachment_allowed_types: ["image/png", "application/pdf"],
        limit_size_total_mime: 52_428_800,
        limit_storage_total: -1,
        limit_count_daily_message_received: 1000,
        limit_count_daily_email_sent: 500,
        limit_inbox_retention_period: 30,
        limit_spam_retention_period: 7
      },
      options: {
        additional_folders: ["Archive"],
        use_cidr_aliasing: false
      },
      spam_detection: {
        use_list_dnsbl: false,
        use_header_anomaly_detection: false,
        spam_sensitivity: 1.0
      },
      created_at: 1_234_567_890,
      updated_at: 1_234_567_890
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get_list method with the correct parameters" do
      path = "#{api_uri}/v3/policies"
      allow(policies).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      policies_response = policies.list(query_params: nil)

      expect(policies_response).to eq(list_response)
    end

    it "calls the get_list method with the correct parameters and query params" do
      query_params = { limit: 10, page_token: "cursor-abc" }
      path = "#{api_uri}/v3/policies"
      allow(policies).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      policies_response = policies.list(query_params: query_params)

      expect(policies_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      policy_id = "policy-123"
      path = "#{api_uri}/v3/policies/#{policy_id}"
      allow(policies).to receive(:get)
        .with(path: path)
        .and_return(response)

      policy_response = policies.find(policy_id: policy_id)

      expect(policy_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        name: "Agent default policy",
        rules: ["rule-123"],
        limits: {
          limit_count_daily_message_received: 1000,
          limit_count_daily_email_sent: 500,
          limit_storage_total: -1
        },
        options: { use_cidr_aliasing: false },
        spam_detection: { spam_sensitivity: 1.0 }
      }
      path = "#{api_uri}/v3/policies"
      allow(policies).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      policy_response = policies.create(request_body: request_body)

      expect(policy_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      policy_id = "policy-123"
      request_body = {
        name: "Updated policy",
        limits: { limit_count_daily_email_sent: 750 }
      }
      path = "#{api_uri}/v3/policies/#{policy_id}"
      allow(policies).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      policy_response = policies.update(policy_id: policy_id, request_body: request_body)

      expect(policy_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      policy_id = "policy-123"
      path = "#{api_uri}/v3/policies/#{policy_id}"
      allow(policies).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      policy_response = policies.destroy(policy_id: policy_id)

      expect(policy_response).to eq([true, "mock_request_id"])
    end
  end
end
