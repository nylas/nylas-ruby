# frozen_string_literal: true

describe Nylas::Sessions do
  let(:sessions) { described_class.new(client) }
  let(:response) do
    [{
      "session_id": "session-id-123"
    }, "mock_request_id"]
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        configuration_id: "configuration-123",
        time_to_live: 30
      }
      path = "#{api_uri}/v3/scheduling/sessions"
      allow(sessions).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      sessions_response = sessions.create(request_body: request_body)
      expect(sessions_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      session_id = "session-123"
      path = "#{api_uri}/v3/scheduling/sessions/#{session_id}"
      allow(sessions).to receive(:delete)
        .with(path: path)
        .and_return([true, "mock_request_id"])

      sessions_response = sessions.destroy(session_id: session_id)
      expect(sessions_response).to eq([true, "mock_request_id"])
    end
  end
end
