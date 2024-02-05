# frozen_string_literal: true

describe Nylas::Connectors do
  let(:connectors) { described_class.new(client) }
  let(:response) do
    {
      provider: "google",
      settings: { topic_name: "abc123" },
      scope: %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
    }
  end

  describe "#initialize" do
    it "initializes the Credentials object" do
      expect(connectors.credentials).to be_a(Nylas::Credentials)
    end
  end

  describe "#list" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/connectors"
      list_response = [[response[0]], response[1]]
      allow(connectors).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      connectors_response = connectors.list(query_params: nil)

      expect(connectors_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      path = "#{api_uri}/v3/connectors"
      query_params = { foo: "bar" }
      list_response = [[response[0]], response[1]]
      allow(connectors).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      connectors_response = connectors.list(query_params: query_params)

      expect(connectors_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      provider = "google"
      path = "#{api_uri}/v3/connectors/#{provider}"
      allow(connectors).to receive(:get)
        .with(path: path)
        .and_return(response)

      connector_response = connectors.find(provider: provider)

      expect(connector_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        provider: "google",
        settings: {
          client_id: "string",
          client_secret: "string",
          topic_name: "string"
        },
        scope: %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
      }
      path = "#{api_uri}/v3/connectors"
      allow(connectors).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      connector_response = connectors.create(request_body: request_body)

      expect(connector_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      provider = "google"
      request_body = {
        settings: {
          client_id: "string",
          client_secret: "string",
          topic_name: "string"
        },
        scope: %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
      }
      path = "#{api_uri}/v3/connectors/#{provider}"
      allow(connectors).to receive(:patch)
        .with(path: path, request_body: request_body)
        .and_return(response)

      connector_response = connectors.update(provider: provider, request_body: request_body)

      expect(connector_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      provider = "google"
      path = "#{api_uri}/v3/connectors/#{provider}"
      allow(connectors).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      connector_response = connectors.destroy(provider: provider)

      expect(connector_response).to eq([true, "mock_request_id"])
    end
  end
end
