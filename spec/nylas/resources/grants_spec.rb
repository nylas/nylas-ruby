# frozen_string_literal: true

describe Nylas::Grants do
  let(:grants) { described_class.new(client) }
  let(:response) do
    {
      id: "e19f8e1a-eb1c-41c0-b6a6-d2e59daf7f47",
      provider: "google",
      grant_status: "valid",
      email: "email@example.com",
      scope: %w[Mail.Read User.Read offline_access],
      user_agent: "string",
      ip: "string",
      state: "my-state",
      created_at: 1617817109,
      updated_at: 1617817109
    }
  end

  describe "#list" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/grants"
      list_response = [[response[0]], response[1]]
      allow(grants).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      grants_response = grants.list

      expect(grants_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      grant_id = "grant-123"
      path = "#{api_uri}/v3/grants/#{grant_id}"
      allow(grants).to receive(:get)
        .with(path: path)
        .and_return(response)

      grant_response = grants.find(grant_id: grant_id)

      expect(grant_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      grant_id = "grant-123"
      request_body = {
        settings: {
          client_id: "string",
          client_secret: "string"
        },
        scope: %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
      }
      path = "#{api_uri}/v3/grants/#{grant_id}"
      allow(grants).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      grant_response = grants.update(grant_id: grant_id, request_body: request_body)

      expect(grant_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      grant_id = "grant-123"
      path = "#{api_uri}/v3/grants/#{grant_id}"
      allow(grants).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      grant_response = grants.destroy(grant_id: grant_id)

      expect(grant_response).to eq([true, "mock_request_id"])
    end
  end
end
