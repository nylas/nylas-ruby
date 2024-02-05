# frozen_string_literal: true

describe Nylas::Attachments do
  let(:attachments) { described_class.new(client) }
  let(:response) do
    [{
      "content_type": "image/png",
      "filename": "pic.png",
      "grant_id": "41009df5-bf11-4c97-aa18-b285b5f2e386",
      "id": "185e56cb50e12e82",
      "is_inline": true,
      "size": 13068,
      "content_id": "<ce9b9547-9eeb-43b2-ac4e-58768bdf04e4>"
    }, "mock_request_id"]
  end
  let(:raw_response) { "raw_response" }

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      attachment_id = "185e56cb50e12e82"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}"
      allow(attachments).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      response = attachments.find(identifier: identifier, attachment_id: attachment_id,
                                  query_params: query_params)

      expect(response).to eq(response)
    end
  end

  describe "#download" do
    it "calls the download_request method with the correct parameters" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      attachment_id = "185e56cb50e12e82"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}/download"
      allow(attachments).to receive(:download_request)
        .with(path: path, query: query_params, api_key: api_key, timeout: timeout)
        .and_return(raw_response)

      response = attachments.download(identifier: identifier, attachment_id: attachment_id,
                                      query_params: query_params)

      expect(response).to eq(raw_response)
    end

    it "calls the download_request method with the correct parameters and block" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      attachment_id = "185e56cb50e12e82"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}/download"
      allow(attachments).to receive(:download_request)
        .with(path: path, query: query_params, api_key: api_key, timeout: timeout)
        .and_return(raw_response)

      response = attachments.download(identifier: identifier, attachment_id: attachment_id,
                                      query_params: query_params) { |chunk| chunk }

      expect(response).to eq(raw_response)
    end
  end

  describe "#download_bytes" do
    it "calls the download_request method with the correct parameters" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      attachment_id = "185e56cb50e12e82"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/attachments/#{attachment_id}/download"
      allow(attachments).to receive(:download_request)
        .with(path: path, query: query_params, api_key: api_key, timeout: timeout)
        .and_return(raw_response)

      response = attachments.download_bytes(identifier: identifier, attachment_id: attachment_id,
                                            query_params: query_params)

      expect(response).to eq(raw_response.bytes)
    end
  end
end
