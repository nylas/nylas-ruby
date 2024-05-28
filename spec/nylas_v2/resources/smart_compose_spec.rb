# frozen_string_literal: true

describe NylasV2::SmartCompose do
  let(:smart_compose) { described_class.new(client) }
  let(:response) do
    [{ suggestion: "Hello world" }, "mock_request_id"]
  end

  describe "#compose_message" do
    it "calls the post method with the correct parameters" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      request_body = { prompt: "hello world" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/smart-compose"
      allow(smart_compose).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      response = smart_compose.compose_message(identifier: identifier, request_body: request_body)

      expect(response).to eq(response)
    end
  end

  describe "#compose_message_reply" do
    it "calls the post method with the correct parameters" do
      identifier = "41009df5-bf11-4c97-aa18-b285b5f2e386"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = { prompt: "hello world" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}/smart-compose"
      allow(smart_compose).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      response = smart_compose.compose_message_reply(identifier: identifier, message_id: message_id,
                                                     request_body: request_body)

      expect(response).to eq(response)
    end
  end
end
