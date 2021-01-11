# frozen_string_literal: true

require "spec_helper"

describe Nylas::NewMessage do
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
      file_ids: [1234, 5678],
      tracking: { opens: true }
    }

    it "sends the message directly" do
      api = instance_double(Nylas::API)

      allow(api).to receive(:send!)

      api.send!(data)

      expect(api).to have_received(:send!).with(data)
    end
  end
end
