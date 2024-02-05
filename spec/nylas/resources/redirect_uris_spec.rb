# frozen_string_literal: true

describe Nylas::RedirectUris do
  let(:redirect_uris) { described_class.new(client) }
  let(:response) do
    {
      id: "0556d035-6cb6-4262-a035-6b77e11cf8fc",
      url: "http://localhost/abc",
      platform: "web",
      settings: {
        origin: "string",
        bundle_id: "string",
        app_store_id: "string",
        team_id: "string",
        package_name: "string",
        sha1_certificate_fingerprint: "string"
      }
    }
  end

  describe "#list" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/applications/redirect-uris"
      list_response = [[response[0]], response[1]]
      allow(redirect_uris).to receive(:get)
        .with(path: path)
        .and_return(list_response)

      redirect_uris_response = redirect_uris.list

      expect(redirect_uris_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      redirect_uri_id = "redirect_uri-123"
      path = "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}"
      allow(redirect_uris).to receive(:get)
        .with(path: path)
        .and_return(response)

      redirect_uri_response = redirect_uris.find(redirect_uri_id: redirect_uri_id)

      expect(redirect_uri_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        url: "http://localhost/abc",
        platform: "web",
        settings: {
          origin: "string",
          bundle_id: "string",
          app_store_id: "string",
          team_id: "string",
          package_name: "string",
          sha1_certificate_fingerprint: "string"
        }
      }
      path = "#{api_uri}/v3/applications/redirect-uris"
      allow(redirect_uris).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      redirect_uri_response = redirect_uris.create(request_body: request_body)

      expect(redirect_uri_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      redirect_uri_id = "redirect_uri-123"
      request_body = {
        url: "http://localhost/abc",
        platform: "web",
        settings: {
          origin: "string",
          bundle_id: "string",
          app_store_id: "string",
          team_id: "string",
          package_name: "string",
          sha1_certificate_fingerprint: "string"
        }
      }
      path = "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}"
      allow(redirect_uris).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      redirect_uri_response = redirect_uris.update(redirect_uri_id: redirect_uri_id,
                                                   request_body: request_body)

      expect(redirect_uri_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      redirect_uri_id = "redirect_uri-123"
      path = "#{api_uri}/v3/applications/redirect-uris/#{redirect_uri_id}"
      allow(redirect_uris).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      redirect_uri_response = redirect_uris.destroy(redirect_uri_id: redirect_uri_id)

      expect(redirect_uri_response).to eq([true, "mock_request_id"])
    end
  end
end
