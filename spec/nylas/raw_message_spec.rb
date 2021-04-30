# frozen_string_literal: true

describe Nylas::RawMessage do
  describe ".#send!" do
    it "calls execute on api with params" do
      message_string = "MIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\n" \
        "Subject: A mime email\n" \
        "From: You <your-email@example.com>\n" \
        "To: You <#{ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-real@example.com')}>\n\n" \
        "This is the body of the message sent as a raw mime!"
      api = FakeAPI.new
      # collection = Nylas::Message.new(model: FullModel, api: api)
      example_instance_hash = { id: "1234" }
      allow(api).to receive(:execute).and_return(example_instance_hash)
      message = described_class.new(message_string, api: api)

      message.send!

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/send",
        payload: message_string,
        headers: { "Content-type" => "message/rfc822" }
      )
    end
  end
end
