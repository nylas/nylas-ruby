# frozen_string_literal: true

describe Nylas::Drafts do
  let(:drafts) { described_class.new(client) }
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
      object: "draft",
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

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/drafts"
      allow(drafts).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      drafts_response = drafts.list(identifier: identifier)

      expect(drafts_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/drafts"
      allow(drafts).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      drafts_response = drafts.list(identifier: identifier, query_params: query_params)

      expect(drafts_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      allow(drafts).to receive(:get)
        .with(path: path)
        .and_return(response)

      draft_response = drafts.find(identifier: identifier, draft_id: draft_id)

      expect(draft_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message."
      }
      path = "#{api_uri}/v3/grants/#{identifier}/drafts"

      allow(drafts).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      draft_response = drafts.create(identifier: identifier, request_body: request_body)

      expect(draft_response).to eq(response)
    end

    it "calls the post method with the correct parameters for small attachments" do
      identifier = "abc-123-grant-id"
      mock_file = instance_double("file")
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message.",
        attachments: [{
          filename: "file.txt",
          content_type: "text/plain",
          size: 100,
          content: mock_file
        }]
      }
      path = "#{api_uri}/v3/grants/#{identifier}/drafts"

      allow(drafts).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      draft_response = drafts.create(identifier: identifier, request_body: request_body)

      expect(draft_response).to eq(response)
    end

    it "calls the post method with the correct parameters for large attachments" do
      identifier = "abc-123-grant-id"
      mock_file = instance_double("file")
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message."
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
      path = "#{api_uri}/v3/grants/#{identifier}/drafts"

      allow(mock_file).to receive(:close)
      allow(drafts).to receive(:post)
        .with(path: path, request_body: expected_compiled_request)
        .and_return(response)

      draft_response = drafts.create(identifier: identifier, request_body: request_body_with_attachments)

      expect(draft_response).to eq(response)
      expect(mock_file).to have_received(:close)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message."
      }
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      allow(drafts).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      draft_response = drafts.update(identifier: identifier, draft_id: draft_id,
                                     request_body: request_body)

      expect(draft_response).to eq(response)
    end

    it "calls the put method with the correct parameters and attachments" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      mock_file = instance_double("file")
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message.",
        attachments: [{
          filename: "file.txt",
          content_type: "text/plain",
          size: 100,
          content: mock_file
        }]
      }
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      allow(drafts).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      draft_response = drafts.update(identifier: identifier, draft_id: draft_id,
                                     request_body: request_body)

      expect(draft_response).to eq(response)
    end

    it "calls the put method with the correct parameters for large attachments" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      mock_file = instance_double("file")
      request_body = {
        subject: "Hello from Nylas!",
        to: [{ name: "Jon Snow", email: "jsnow@gmail.com" }],
        cc: [{ name: "Arya Stark", email: "astark@gmail.com" }],
        body: "This is the body of my draft message."
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
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"

      allow(mock_file).to receive(:close)
      allow(drafts).to receive(:put)
        .with(path: path, request_body: expected_compiled_request)
        .and_return(response)

      draft_response = drafts.update(identifier: identifier, draft_id: draft_id,
                                     request_body: request_body_with_attachments)

      expect(draft_response).to eq(response)
      expect(mock_file).to have_received(:close)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      allow(drafts).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      draft_response = drafts.destroy(identifier: identifier, draft_id: draft_id)

      expect(draft_response).to eq([true, response[1]])
    end
  end

  describe "#send" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      draft_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/drafts/#{draft_id}"
      allow(drafts).to receive(:post)
        .with(path: path)
        .and_return(response)

      draft_response = drafts.send(identifier: identifier, draft_id: draft_id)

      expect(draft_response).to eq(response)
    end
  end
end
