# frozen_string_literal: true

describe Nylas::Rules do
  let(:rules) { described_class.new(client) }
  let(:rule) do
    {
      id: "rule-123",
      name: "Block spammers",
      description: "Block messages from a domain",
      priority: 10,
      enabled: true,
      trigger: "inbound",
      match: {
        operator: "all",
        conditions: [
          { field: "from.domain", operator: "is", value: "spam.example.com" }
        ]
      },
      actions: [
        { type: "block" }
      ],
      application_id: "app-123",
      organization_id: "org-123",
      created_at: 1234567890,
      updated_at: 1234567890
    }
  end

  describe "#list" do
    it "unwraps the nested list envelope and returns items, request id, next cursor, and headers" do
      path = "#{api_uri}/v3/rules"
      query_params = { limit: 10 }
      raw_response = {
        request_id: "req-123",
        data: {
          items: [rule],
          next_cursor: "cursor-abc"
        },
        headers: { "x-request-id" => "req-123" }
      }
      allow(rules).to receive(:get_raw)
        .with(path: path, query_params: query_params)
        .and_return(raw_response)

      result = rules.list(query_params: query_params)

      expect(result).to eq([[rule], "req-123", "cursor-abc", { "x-request-id" => "req-123" }])
    end

    it "omits next_cursor when the nested envelope has none" do
      path = "#{api_uri}/v3/rules"
      raw_response = {
        request_id: "req-123",
        data: { items: [rule] }
      }
      allow(rules).to receive(:get_raw)
        .with(path: path, query_params: nil)
        .and_return(raw_response)

      result = rules.list

      expect(result).to eq([[rule], "req-123", nil, nil])
    end

    it "coerces a null items slice to an empty array (Go nil-slice marshals as items: null)" do
      path = "#{api_uri}/v3/rules"
      raw_response = {
        request_id: "req-123",
        data: { items: nil, next_cursor: nil }
      }
      allow(rules).to receive(:get_raw)
        .with(path: path, query_params: nil)
        .and_return(raw_response)

      result = rules.list

      expect(result).to eq([[], "req-123", nil, nil])
    end

    it "falls back gracefully when data is a flat array" do
      path = "#{api_uri}/v3/rules"
      raw_response = {
        request_id: "req-123",
        data: [rule],
        next_cursor: "cursor-flat"
      }
      allow(rules).to receive(:get_raw)
        .with(path: path, query_params: nil)
        .and_return(raw_response)

      result = rules.list

      expect(result).to eq([[rule], "req-123", "cursor-flat", nil])
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      rule_id = "rule-123"
      path = "#{api_uri}/v3/rules/#{rule_id}"
      allow(rules).to receive(:get)
        .with(path: path)
        .and_return([rule, "req-123"])

      result = rules.find(rule_id: rule_id)

      expect(result).to eq([rule, "req-123"])
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        name: "Block spammers",
        match: {
          conditions: [
            { field: "from.domain", operator: "is", value: "spam.example.com" }
          ]
        },
        actions: [{ type: "block" }]
      }
      path = "#{api_uri}/v3/rules"
      allow(rules).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return([rule, "req-123"])

      result = rules.create(request_body: request_body)

      expect(result).to eq([rule, "req-123"])
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      rule_id = "rule-123"
      request_body = { enabled: false }
      path = "#{api_uri}/v3/rules/#{rule_id}"
      allow(rules).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return([rule, "req-123"])

      result = rules.update(rule_id: rule_id, request_body: request_body)

      expect(result).to eq([rule, "req-123"])
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      rule_id = "rule-123"
      path = "#{api_uri}/v3/rules/#{rule_id}"
      allow(rules).to receive(:delete)
        .with(path: path)
        .and_return([nil, "req-123"])

      result = rules.destroy(rule_id: rule_id)

      expect(result).to eq([true, "req-123"])
    end
  end

  describe "#list_evaluations" do
    let(:evaluation) do
      {
        id: "eval-123",
        grant_id: "grant-123",
        message_id: nil,
        evaluated_at: 1234567890,
        evaluation_stage: "inbox_processing",
        evaluation_input: { from_address: "sender@example.com" },
        applied_actions: { blocked: true },
        matched_rule_ids: ["rule-123"],
        application_id: "app-123",
        organization_id: "org-123",
        created_at: 1234567890,
        updated_at: 1234567890
      }
    end

    it "calls the get_list method with the correct parameters" do
      grant_id = "grant-123"
      path = "#{api_uri}/v3/grants/#{grant_id}/rule-evaluations"
      query_params = { limit: 10 }
      list_response = [[evaluation], "req-123", nil, {}]
      allow(rules).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      result = rules.list_evaluations(grant_id: grant_id, query_params: query_params)

      expect(result).to eq(list_response)
    end

    it "passes nil query params when none are provided" do
      grant_id = "grant-123"
      path = "#{api_uri}/v3/grants/#{grant_id}/rule-evaluations"
      list_response = [[evaluation], "req-123", nil, {}]
      allow(rules).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      result = rules.list_evaluations(grant_id: grant_id)

      expect(result).to eq(list_response)
    end
  end
end
