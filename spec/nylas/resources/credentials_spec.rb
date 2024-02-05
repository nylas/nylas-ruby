# frozen_string_literal: true

describe Nylas::Credentials do
  let(:credentials) { described_class.new(client) }
  let(:response) do
    {
      id: "e19f8e1a-eb1c-41c0-b6a6-d2e59daf7f47",
      name: "My first Google credential",
      created_at: 1617817109,
      updated_at: 1617817109
    }
  end

  describe "#list" do
    it "calls the get method with the correct parameters" do
      provider = "google"
      path = "#{api_uri}/v3/connectors/#{provider}/creds"
      list_response = [[response[0]], response[1]]
      allow(credentials).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      credentials_response = credentials.list(provider: provider, query_params: nil)

      expect(credentials_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      provider = "google"
      path = "#{api_uri}/v3/connectors/#{provider}/creds"
      query_params = { foo: "bar" }
      list_response = [[response[0]], response[1]]
      allow(credentials).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      credentials_response = credentials.list(provider: provider, query_params: query_params)

      expect(credentials_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      provider = "google"
      credential_id = "creds-123"
      path = "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}"
      allow(credentials).to receive(:get)
        .with(path: path)
        .and_return(response)

      credential_response = credentials.find(provider: provider, credential_id: credential_id)

      expect(credential_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      provider = "google"
      request_body = {
        name: "My first Google credential",
        credential_type: "serviceaccount",
        credential_data: {
          private_key_id: "string",
          private_key: "string",
          client_email: "string"
        }
      }
      path = "#{api_uri}/v3/connectors/#{provider}/creds"
      allow(credentials).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      credential_response = credentials.create(provider: provider, request_body: request_body)

      expect(credential_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      provider = "google"
      credential_id = "creds-123"
      request_body = {
        name: "My first Google credential",
        credential_data: {
          private_key_id: "string",
          private_key: "string",
          client_email: "string"
        }
      }
      path = "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}"
      allow(credentials).to receive(:patch)
        .with(path: path, request_body: request_body)
        .and_return(response)

      credential_response = credentials.update(provider: provider, credential_id: credential_id,
                                               request_body: request_body)

      expect(credential_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      provider = "google"
      credential_id = "creds-123"
      path = "#{api_uri}/v3/connectors/#{provider}/creds/#{credential_id}"
      allow(credentials).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      credential_response = credentials.destroy(provider: provider, credential_id: credential_id)

      expect(credential_response).to eq([true, "mock_request_id"])
    end
  end
end
