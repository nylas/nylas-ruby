# frozen_string_literal: true

describe Nylas::Workspaces do
  let(:workspaces) { described_class.new(client) }
  let(:response) do
    {
      workspace_id: "5967ca40-1234-4321-abcd-1234567890ab",
      application_id: "abc12345-1234-4321-abcd-1234567890ab",
      name: "Acme Engineering",
      domain: "acme.com",
      auto_group: true,
      created_at: 1_234_567_890,
      updated_at: 1_234_567_890
    }
  end

  describe "#list" do
    it "calls the get method with the correct path" do
      path = "#{api_uri}/v3/workspaces"
      list_response = [[response], "mock_request_id", {}]
      allow(workspaces).to receive(:get)
        .with(path: path)
        .and_return(list_response)

      workspaces_response = workspaces.list

      expect(workspaces).to have_received(:get).with(path: path)
      expect(workspaces_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct path" do
      workspace_id = "workspace-123"
      path = "#{api_uri}/v3/workspaces/#{workspace_id}"
      allow(workspaces).to receive(:get)
        .with(path: path)
        .and_return(response)

      workspace_response = workspaces.find(workspace_id: workspace_id)

      expect(workspaces).to have_received(:get).with(path: path)
      expect(workspace_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct path and body" do
      request_body = {
        name: "Acme Engineering",
        domain: "acme.com",
        auto_group: true,
        policy_id: "policy-123",
        rule_ids: ["rule-123"]
      }
      path = "#{api_uri}/v3/workspaces"
      allow(workspaces).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      workspace_response = workspaces.create(request_body: request_body)

      expect(workspaces).to have_received(:post).with(path: path, request_body: request_body)
      expect(workspace_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct path and body" do
      workspace_id = "workspace-123"
      request_body = { name: "Renamed Workspace", policy_id: "policy-456" }
      path = "#{api_uri}/v3/workspaces/#{workspace_id}"
      allow(workspaces).to receive(:patch)
        .with(path: path, request_body: request_body)
        .and_return([response, "mock_request_id"])

      workspace_response = workspaces.update(workspace_id: workspace_id, request_body: request_body)

      expect(workspaces).to have_received(:patch).with(path: path, request_body: request_body)
      expect(workspace_response).to eq([response, "mock_request_id"])
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct path" do
      workspace_id = "workspace-123"
      path = "#{api_uri}/v3/workspaces/#{workspace_id}"
      allow(workspaces).to receive(:delete)
        .with(path: path)
        .and_return([nil, "mock_request_id"])

      workspace_response = workspaces.destroy(workspace_id: workspace_id)

      expect(workspaces).to have_received(:delete).with(path: path)
      expect(workspace_response).to eq([true, "mock_request_id"])
    end
  end

  describe "#auto_group" do
    it "calls the post method with the correct path and body" do
      request_body = { specific_domain: "acme.com", invalid_also: false }
      path = "#{api_uri}/v3/workspaces/auto-group"
      job_response = {
        job_id: "job-123",
        message: "Auto-grouping started successfully under JobID 'job-123'."
      }
      allow(workspaces).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(job_response)

      workspace_response = workspaces.auto_group(request_body: request_body)

      expect(workspaces).to have_received(:post).with(path: path, request_body: request_body)
      expect(workspace_response).to eq(job_response)
    end

    it "defaults the request body to nil when not provided" do
      path = "#{api_uri}/v3/workspaces/auto-group"
      allow(workspaces).to receive(:post)
        .with(path: path, request_body: nil)

      workspaces.auto_group

      expect(workspaces).to have_received(:post).with(path: path, request_body: nil)
    end
  end

  describe "#manual_assign" do
    it "calls the post method with the correct path and body" do
      workspace_id = "workspace-123"
      request_body = {
        assign_grants: ["grant-123"],
        remove_grants: ["grant-456"]
      }
      path = "#{api_uri}/v3/workspaces/#{workspace_id}/manual-assign"
      assign_response = {
        application_id: "abc12345-1234-4321-abcd-1234567890ab",
        workspace_id: workspace_id,
        domain: "acme.com",
        grants_assigned: ["grant-123"],
        grants_removed: ["grant-456"]
      }
      allow(workspaces).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(assign_response)

      workspace_response = workspaces.manual_assign(workspace_id: workspace_id, request_body: request_body)

      expect(workspaces).to have_received(:post).with(path: path, request_body: request_body)
      expect(workspace_response).to eq(assign_response)
    end
  end
end
