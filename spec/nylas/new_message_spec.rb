# frozen_string_literal: true

require "spec_helper"

describe Nylas::NewMessage do
  let(:api) { FakeAPI.new }

  describe "#send!" do
    data = {
      reply_to_message_id: "mess-1234",
      to: [{ email: "to@example.com", name: "To Example" }],
      from: [{ email: "from@example.com", name: "From Example" }],
      cc: [{ email: "cc@example.com", name: "CC Example" }],
      bcc: [{ email: "bcc@example.com", name: "BCC Example" }],
      reply_to: [{ email: "reply-to@example.com", name: "Reply To Example" }],
      subject: "A draft emails subject",
      body: "<h1>A draft Email</h1>",
      file_ids: ["1234", "5678"],
      tracking: { opens: true },
    }

    it "directly sends the message" do
      api = instance_double(Nylas::API)
      new_message = described_class.from_json(
        JSON.dump(data),
        api: api
      )

      allow(api).to receive(:execute)

      new_message.send!

      expect(api).to have_received(:execute).with(method: :post, path: "/send",
                                                  payload: JSON.dump(data))
    end
  end

end