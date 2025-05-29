# frozen_string_literal: true

describe Nylas::Messages do
  let(:messages) { described_class.new(client) }
  let(:response) do
    [{
      body: "Hello, I just sent a message using Nylas!",
      cc: [{ email: "arya.stark@example.com" }],
      attachments: [
        {
          content_type: "text/calendar",
          id: "4kj2jrcoj9ve5j9yxqz5cuv98",
          size: 1708
        }
      ],
      folders: %w[8l6c4d11y1p4dm4fxj52whyr9 d9zkcr2tljpu3m4qpj7l2hbr0],
      from: [{ name: "Daenerys Targaryen", email: "daenerys.t@example.com" }],
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      id: "5d3qmne77v32r8l4phyuksl2x",
      object: "message",
      reply_to: [
        { name: "Daenerys Targaryen", email: "daenerys.t@example.com" }
      ],
      snippet: "Hello, I just sent a message using Nylas!",
      starred: true,
      subject: "Hello from Nylas!",
      thread_id: "1t8tv3890q4vgmwq6pmdwm8qgsaer",
      to: [{ name: "Jon Snow", email: "j.snow@example.com" }],
      date: 1705084742,
      created_at: 1705084926
    }, "mock_request_id"]
  end

  let(:response_with_tracking_options) do
    [{
      body: "Hello, I just sent a message using Nylas!",
      cc: [{ email: "arya.stark@example.com" }],
      attachments: [
        {
          content_type: "text/calendar",
          id: "4kj2jrcoj9ve5j9yxqz5cuv98",
          size: 1708
        }
      ],
      folders: %w[8l6c4d11y1p4dm4fxj52whyr9 d9zkcr2tljpu3m4qpj7l2hbr0],
      from: [{ name: "Daenerys Targaryen", email: "daenerys.t@example.com" }],
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      id: "5d3qmne77v32r8l4phyuksl2x",
      object: "message",
      reply_to: [
        { name: "Daenerys Targaryen", email: "daenerys.t@example.com" }
      ],
      snippet: "Hello, I just sent a message using Nylas!",
      starred: true,
      subject: "Hello from Nylas!",
      thread_id: "1t8tv3890q4vgmwq6pmdwm8qgsaer",
      to: [{ name: "Jon Snow", email: "j.snow@example.com" }],
      date: 1705084742,
      created_at: 1705084926,
      tracking_options: {
        opens: true,
        thread_replies: false,
        links: true,
        label: "Marketing Campaign 2025"
      }
    }, "mock_request_id"]
  end

  let(:response_with_raw_mime) do
    [{
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      object: "message",
      id: "5d3qmne77v32r8l4phyuksl2x",
      raw_mime: "UmVjZWl2ZWQ6IGZyb20gc21pcDEyMy5tYWlsLmdtYWlsLmNvbSAoW0ZGRkZGRkZGRkZGRkZGRkY6" \
                 "MTkyLjE2OC4xLjFdKSBieSBteGNvcC5nb29nbGVjb21wdXRlLmNvbQo="
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/messages"
      allow(messages).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      messages_response = messages.list(identifier: identifier)

      expect(messages_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages"
      allow(messages).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      messages_response = messages.list(identifier: identifier, query_params: query_params)

      expect(messages_response).to eq(list_response)
    end

    it "calls the get method with fields=include_tracking_options" do
      identifier = "abc-123-grant-id"
      query_params = { fields: "include_tracking_options" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages"
      list_response_with_tracking = [
        [response_with_tracking_options[0]], response_with_tracking_options[1], "mock_next_cursor"
      ]
      allow(messages).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response_with_tracking)

      messages_response = messages.list(identifier: identifier, query_params: query_params)

      expect(messages_response).to eq(list_response_with_tracking)
      expect(messages_response[0][0][:tracking_options]).not_to be_nil
      expect(messages_response[0][0][:tracking_options][:opens]).to be(true)
      expect(messages_response[0][0][:tracking_options][:thread_replies]).to be(false)
      expect(messages_response[0][0][:tracking_options][:links]).to be(true)
      expect(messages_response[0][0][:tracking_options][:label]).to eq("Marketing Campaign 2025")
    end

    it "calls the get method with fields=raw_mime" do
      identifier = "abc-123-grant-id"
      query_params = { fields: "raw_mime" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages"
      list_response_with_raw_mime = [
        [response_with_raw_mime[0]], response_with_raw_mime[1], "mock_next_cursor"
      ]
      allow(messages).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response_with_raw_mime)

      messages_response = messages.list(identifier: identifier, query_params: query_params)

      expect(messages_response).to eq(list_response_with_raw_mime)
      expect(messages_response[0][0][:raw_mime]).not_to be_nil
      expect(messages_response[0][0][:raw_mime]).to match(%r{^[A-Za-z0-9+/]*={0,2}$}) # Base64 pattern
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { fields: "include_headers" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      message_response = messages.find(identifier: identifier, message_id: message_id,
                                       query_params: query_params)

      expect(message_response).to eq(response)
    end

    it "calls the get method with fields=include_tracking_options" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { fields: "include_tracking_options" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response_with_tracking_options)

      message_response = messages.find(identifier: identifier, message_id: message_id,
                                       query_params: query_params)

      expect(message_response).to eq(response_with_tracking_options)
      expect(message_response[0][:tracking_options]).not_to be_nil
      expect(message_response[0][:tracking_options][:opens]).to be(true)
      expect(message_response[0][:tracking_options][:thread_replies]).to be(false)
      expect(message_response[0][:tracking_options][:links]).to be(true)
      expect(message_response[0][:tracking_options][:label]).to eq("Marketing Campaign 2025")
    end

    it "calls the get method with fields=raw_mime" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { fields: "raw_mime" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response_with_raw_mime)

      message_response = messages.find(identifier: identifier, message_id: message_id,
                                       query_params: query_params)

      expect(message_response).to eq(response_with_raw_mime)
      expect(message_response[0][:raw_mime]).not_to be_nil
      expect(message_response[0][:raw_mime]).to match(%r{^[A-Za-z0-9+/]*={0,2}$}) # Base64 pattern
      # When raw_mime is requested, only grant_id, object, id, and raw_mime should be present
      expect(message_response[0].keys.sort).to eq(%i[grant_id id object raw_mime])
    end

    it "calls the get method with fields=standard (default behavior)" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { fields: "standard" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      message_response = messages.find(identifier: identifier, message_id: message_id,
                                       query_params: query_params)

      expect(message_response).to eq(response)
      expect(message_response[0]).not_to have_key(:tracking_options)
      expect(message_response[0]).not_to have_key(:raw_mime)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        starred: true,
        unread: false,
        folders: ["folder-123"],
        metadata: { foo: "bar" }
      }
      query_params = { fields: "include_headers" }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:put)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      message_response = messages.update(identifier: identifier, message_id: message_id,
                                         request_body: request_body, query_params: query_params)

      expect(message_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"
      allow(messages).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      message_response = messages.destroy(identifier: identifier, message_id: message_id)

      expect(message_response).to eq([true, response[1]])
    end
  end

  describe "#send" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my message message."
      }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/send"

      allow(messages).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      message_response = messages.send(identifier: identifier, request_body: request_body)

      expect(message_response).to eq(response)
    end

    it "calls the post method with the correct parameters and attachments" do
      identifier = "abc-123-grant-id"
      mock_file = instance_double("file")
      allow(mock_file).to receive(:read).and_return("file content")
      allow(mock_file).to receive(:close).and_return(true)
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my message message.",
        attachments: [{
          filename: "file.txt",
          content_type: "text/plain",
          size: 100,
          content: mock_file
        }]
      }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/send"

      allow(messages).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      message_response = messages.send(identifier: identifier, request_body: request_body)

      expect(message_response).to eq(response)
    end

    it "calls the post method with the correct parameters and large attachments" do
      identifier = "abc-123-grant-id"
      mock_file = instance_double("file")
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my message message."
      }
      attachment = {
        filename: "file.txt",
        content_type: "text/plain",
        size: 3 * 1024 * 1024,
        content: mock_file
      }
      expected_compiled_request = {
        "multipart" => true,
        "message" => request_body.to_json,
        "file0" => mock_file
      }
      request_body_with_attachments = request_body.merge(attachments: [attachment])
      path = "#{api_uri}/v3/grants/#{identifier}/messages/send"

      allow(mock_file).to receive(:close)
      allow(messages).to receive(:post)
        .with(path: path, request_body: expected_compiled_request)
        .and_return(response)

      message_response = messages.send(identifier: identifier, request_body: request_body_with_attachments)

      expect(message_response).to eq(response)
      expect(mock_file).to have_received(:close)
    end
  end

  describe "#list_scheduled_messages" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/messages/schedules"
      allow(messages).to receive(:get)
        .with(path: path)
        .and_return(response)

      message_response = messages.list_scheduled_messages(identifier: identifier)

      expect(message_response).to eq(response)
    end
  end

  describe "#find_scheduled_messages" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      schedule_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/messages/schedules/#{schedule_id}"
      allow(messages).to receive(:get)
        .with(path: path)
        .and_return(response)

      message_response = messages.find_scheduled_messages(identifier: identifier, schedule_id: schedule_id)

      expect(message_response).to eq(response)
    end
  end

  describe "#stop_scheduled_messages" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      schedule_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/messages/schedules/#{schedule_id}"
      allow(messages).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      message_response = messages.stop_scheduled_messages(identifier: identifier, schedule_id: schedule_id)

      expect(message_response).to eq([true, response[1]])
    end
  end

  describe "MessageFields constants" do
    it "provides the correct field values" do
      expect(Nylas::MessageFields::STANDARD).to eq("standard")
      expect(Nylas::MessageFields::INCLUDE_HEADERS).to eq("include_headers")
      expect(Nylas::MessageFields::INCLUDE_TRACKING_OPTIONS).to eq("include_tracking_options")
      expect(Nylas::MessageFields::RAW_MIME).to eq("raw_mime")
    end

    it "allows using constants in query parameters for list" do
      identifier = "abc-123-grant-id"
      query_params = { fields: Nylas::MessageFields::INCLUDE_TRACKING_OPTIONS }
      path = "#{api_uri}/v3/grants/#{identifier}/messages"
      list_response_with_tracking = [
        [response_with_tracking_options[0]], response_with_tracking_options[1], "mock_next_cursor"
      ]

      allow(messages).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response_with_tracking)

      messages_response = messages.list(identifier: identifier, query_params: query_params)

      expect(messages_response).to eq(list_response_with_tracking)
      expect(messages_response[0][0][:tracking_options]).not_to be_nil
    end

    it "allows using constants in query parameters for find" do
      identifier = "abc-123-grant-id"
      message_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { fields: Nylas::MessageFields::RAW_MIME }
      path = "#{api_uri}/v3/grants/#{identifier}/messages/#{message_id}"

      allow(messages).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response_with_raw_mime)

      message_response = messages.find(identifier: identifier, message_id: message_id,
                                       query_params: query_params)

      expect(message_response).to eq(response_with_raw_mime)
      expect(message_response[0][:raw_mime]).not_to be_nil
    end
  end
end
