# frozen_string_literal: true

describe Nylas::Threads do
  let(:threads) { described_class.new(client) }
  let(:response) do
    [{
      grant_id: "ca8f1733-6063-40cc-a2e3-ec7274abef11",
      id: "7ml84jdmfnw20sq59f30hirhe",
      object: "thread",
      has_attachments: false,
      has_drafts: false,
      earliest_message_date: 1634149514,
      latest_message_received_date: 1634832749,
      latest_message_sent_date: 1635174399,
      participants: [
        { email: "daenerys.t@example.com", name: "Daenerys Targaryen" }
      ],
      snippet: "jnlnnn --Sent with Nylas",
      starred: false,
      subject: "Dinner Wednesday?",
      unread: false,
      message_ids: %w[njeb79kFFzli09 998abue3mGH4sk],
      draft_ids: ["a809kmmoW90Dx"],
      folders: %w[8l6c4d11y1p4dm4fxj52whyr9 d9zkcr2tljpu3m4qpj7l2hbr0],
      latest_draft_or_message: {
        body: "Hello, I just sent a message using Nylas!",
        cc: [{ name: "Arya Stark", email: "arya.stark@example.com" }],
        date: 1635355739,
        attachments: [
          {
            content_type: "text/calendar",
            id: "4kj2jrcoj9ve5j9yxqz5cuv98",
            size: 1708
          }
        ],
        folders: %w[8l6c4d11y1p4dm4fxj52whyr9 d9zkcr2tljpu3m4qpj7l2hbr0],
        from: [
          { name: "Daenerys Targaryen", email: "daenerys.t@example.com" }
        ],
        grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
        id: "njeb79kFFzli09",
        object: "message",
        reply_to: [
          { name: "Daenerys Targaryen", email: "daenerys.t@example.com" }
        ],
        snippet: "Hello, I just sent a message using Nylas!",
        starred: true,
        subject: "Hello from Nylas!",
        thread_id: "1t8tv3890q4vgmwq6pmdwm8qgsaer",
        to: [{ name: "Jon Snow", email: "j.snow@example.com" }],
        unread: true
      }
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/threads"
      allow(threads).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      threads_response = threads.list(identifier: identifier)

      expect(threads_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/threads"
      allow(threads).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      threads_response = threads.list(identifier: identifier, query_params: query_params)

      expect(threads_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      thread_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      allow(threads).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      thread_response = threads.find(identifier: identifier, thread_id: thread_id)

      expect(thread_response).to eq(response)
    end

    it "calls the get method with the correct query parameters" do
      identifier = "abc-123-grant-id"
      thread_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      allow(threads).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      thread_response = threads.find(identifier: identifier, thread_id: thread_id, query_params: query_params)
      expect(thread_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      thread_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        starred: true,
        unread: false,
        folders: ["folder-123"]
      }
      path = "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      allow(threads).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      thread_response = threads.update(identifier: identifier, thread_id: thread_id,
                                       request_body: request_body)

      expect(thread_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      thread_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/threads/#{thread_id}"
      allow(threads).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      thread_response = threads.destroy(identifier: identifier, thread_id: thread_id)

      expect(thread_response).to eq([true, response[1]])
    end
  end
end
