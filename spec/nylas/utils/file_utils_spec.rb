# frozen_string_literal: true

describe Nylas::FileUtils do
  let(:mock_file) { instance_double("file") }

  describe "#attach_file_request_builder" do
    let(:file_path) { "/path/to/file.txt" }
    let(:file_size) { 100 }

    before do
      allow(File).to receive(:size).with(file_path).and_return(file_size)
      allow(File).to receive(:new).with(file_path, "rb").and_return(mock_file)
    end

    it "returns the correct request" do
      file_path = "/path/to/file.txt"

      attach_file_req = described_class.attach_file_request_builder(file_path)

      expect(attach_file_req).to eq(
        filename: "file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file,
        content_id: nil,
        file_path: file_path
      )
    end

    it "defaults the file type to octet-stream if it is not found" do
      file_path = "/path/to/file.txt"
      file_size = 100

      allow(MIME::Types).to receive(:type_for).with(file_path).and_return(nil)

      attach_file_req = described_class.attach_file_request_builder(file_path)

      expect(attach_file_req).to eq(
        filename: "file.txt",
        content_type: "application/octet-stream",
        size: file_size,
        content: mock_file,
        content_id: nil,
        file_path: file_path
      )
    end

    it "accepts optional filename parameter" do
      file_path = "/path/to/file.txt"
      filename = "customm-file.txt"

      attach_file_req = described_class.attach_file_request_builder(file_path, filename)

      expect(attach_file_req).to eq(
        filename: "customm-file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file,
        content_id: nil,
        file_path: file_path
      )
    end

    it "accepts optional content_id parameter" do
      file_path = "/path/to/file.txt"
      content_id = "content-id-123"

      attach_file_req = described_class.attach_file_request_builder(file_path, nil, content_id)

      expect(attach_file_req).to eq(
        filename: "file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file,
        content_id: content_id,
        file_path: file_path
      )
    end
  end

  describe "#build_form_request" do
    let(:attachment) do
      {
        filename: "file.txt",
        content_type: "text/plain",
        size: 100,
        content: mock_file
      }
    end
    let(:request_body) do
      {
        to: [{ email: "test@gmail.com" }],
        subject: "test",
        body: "test"
      }
    end

    it "returns builds the correct form request" do
      request_body_with_attachment = request_body.merge(attachments: [attachment])
      expected_response_form = {
        "multipart" => true,
        "message" => request_body.to_json,
        "file0" => mock_file
      }

      form_request = described_class.build_form_request(request_body_with_attachment)

      expect(form_request).to eq([expected_response_form, [mock_file]])
    end

    # Test for the UTF-8 encoding compatibility - FileUtils should produce standard UTF-8 JSON
    it "produces standard UTF-8 JSON that will be handled by HttpClient for HTTParty compatibility" do
      utf8_request_body = {
        to: [{ email: "test@example.com", name: "Tëst Récipient 👤" }],
        subject: "UTF-8 Test: Ñylas 🚀 Tëst with Émojis",
        body: "Message with UTF-8: ñ, é, ü, 中文, العربية, 🚀 ⚡ 💯"
      }

      request_body_with_attachment = utf8_request_body.merge(attachments: [attachment])

      form_data, _opened_files = described_class.build_form_request(request_body_with_attachment)

      # The message payload should remain UTF-8 encoded (HttpClient will handle HTTParty compatibility)
      message_payload = form_data["message"]
      expect(message_payload.encoding).to eq(Encoding::UTF_8)

      # JSON should contain the original UTF-8 characters
      parsed_message = JSON.parse(message_payload)
      expect(parsed_message["subject"]).to eq("UTF-8 Test: Ñylas 🚀 Tëst with Émojis")
      expect(parsed_message["body"]).to eq("Message with UTF-8: ñ, é, ü, 中文, العربية, 🚀 ⚡ 💯")
      expect(parsed_message["to"][0]["name"]).to eq("Tëst Récipient 👤")
    end

    it "returns the correct form request when there are no attachments" do
      form_request = described_class.build_form_request(request_body)

      expect(form_request).to eq([request_body, []])
    end

    it "raises an error if the file is closed and no file_path is provided" do
      attachments = [{ content: mock_file }]
      request_body = { attachments: attachments }

      allow(mock_file).to receive(:closed?).and_return(true)

      expect do
        described_class.build_form_request(request_body)
      end.to raise_error(ArgumentError, "The file at index 0 is closed and no file_path was provided.")
    end

    it "opens the file if it is closed and file_path is provided" do
      file_path = "/path/to/file.txt"
      attachments = [{ content: mock_file, file_path: file_path }]
      request_body = { attachments: attachments }

      allow(mock_file).to receive(:closed?).and_return(true)
      allow(File).to receive(:open).with(file_path, "rb").and_return(mock_file)

      form_data, opened_files = described_class.build_form_request(request_body)

      expect(form_data).to include("file0" => mock_file)
      expect(opened_files).to include(mock_file)
    end

    it "adds the file to form_data if it is open" do
      attachments = [{ content: mock_file }]
      request_body = { attachments: attachments }

      allow(mock_file).to receive(:closed?).and_return(false)

      form_data, opened_files = described_class.build_form_request(request_body)

      expect(form_data).to include("file0" => mock_file)
      expect(opened_files).to include(mock_file)
    end
  end

  describe "#build_json_request" do
    let(:mock_file) { instance_double("file") }

    it "encodes the content of each attachment" do
      allow(mock_file).to receive(:read).and_return("file content")
      attachments = [{ content: mock_file }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result.first[:content]).to eq(Base64.strict_encode64("file content"))
      expect(opened_files).to include(mock_file)
    end

    it "removed the file_path key from the attachment" do
      attachments = [{ content: mock_file, file_path: "/path/to/file.txt" }]

      result, _opened_files = described_class.build_json_request(attachments)

      expect(result.first).not_to have_key(:file_path)
    end

    it "skips attachments with no content" do
      attachments = [{ content: nil }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result.first[:content]).to be_nil
      expect(opened_files).to be_empty
    end

    it "returns empty arrays when attachments are empty" do
      attachments = []

      result, opened_files = described_class.build_json_request(attachments)

      expect(result).to eq([])
      expect(opened_files).to eq([])
    end

    it "handles multiple attachments" do
      mock_file1 = instance_double("file1")
      mock_file2 = instance_double("file2")
      allow(mock_file1).to receive(:read).and_return("file content 1")
      allow(mock_file2).to receive(:read).and_return("file content 2")
      attachments = [{ content: mock_file1 }, { content: mock_file2 }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result[0][:content]).to eq(Base64.strict_encode64("file content 1"))
      expect(result[1][:content]).to eq(Base64.strict_encode64("file content 2"))
      expect(opened_files).to include(mock_file1, mock_file2)
    end

    it "sends a b64 string without further encoding" do
      attachments = [{ content: "SGVsbG8gd29ybGQ=" }]

      result, opened_files = described_class.build_json_request(attachments)

      expect(result.first[:content]).to match(Base64.strict_encode64("Hello world"))
      expect(opened_files).to be_empty
    end
  end

  describe "#handle_message_payload" do
    let(:mock_file) { instance_double("file") }

    it "returns form data when attachment size is greater than 3MB" do
      large_attachment = {
        size: 4 * 1024 * 1024,
        content: mock_file,
        filename: "file.txt",
        content_type: "text/plain"
      }
      request_body = { attachments: [large_attachment] }

      allow(mock_file).to receive(:read).and_return("file content")
      allow(File).to receive(:size).and_return(large_attachment[:size])

      payload, opened_files = described_class.handle_message_payload(request_body)

      expect(payload).to include("multipart" => true)
      expect(opened_files).to include(mock_file)
      expect(mock_file.original_filename).to eq("file.txt")
      expect(mock_file.content_type).to eq("text/plain")
    end

    it "returns json data when attachment size is less than 3MB" do
      small_attachment = { size: 2 * 1024 * 1024, content: mock_file }
      request_body = { attachments: [small_attachment] }

      allow(mock_file).to receive(:read).and_return("file content")

      payload, opened_files = described_class.handle_message_payload(request_body)

      expect(payload[:attachments].first[:content]).to eq(Base64.strict_encode64("file content"))
      expect(opened_files).to include(mock_file)
    end

    it "returns json data when there are no attachments" do
      request_body = { attachments: [] }

      payload, opened_files = described_class.handle_message_payload(request_body)

      expect(payload[:attachments]).to eq([])
      expect(opened_files).to eq([])
    end

    it "returns json data when attachments is nil" do
      request_body = { attachments: nil }

      payload, opened_files = described_class.handle_message_payload(request_body)

      expect(payload[:attachments]).to be_nil
      expect(opened_files).to eq([])
    end

    it "handles multiple attachments with mixed sizes" do
      small_attachment = { size: 2 * 1024 * 1024, content: mock_file }
      large_attachment = { size: 4 * 1024 * 1024, content: mock_file }
      request_body = { attachments: [small_attachment, large_attachment] }

      allow(mock_file).to receive(:read).and_return("file content")
      allow(File).to receive(:size).and_return(small_attachment[:size], large_attachment[:size])

      payload, opened_files = described_class.handle_message_payload(request_body)

      expect(payload).to include("multipart" => true)
      expect(opened_files).to include(mock_file)
    end

    # Test for the bug fix: ensure FileUtils.handle_message_payload output works with HttpClient.build_request
    it "produces payload compatible with HttpClient.build_request (fixes issue #525)" do
      # Create a test HTTP client to test the integration
      test_client = Class.new do
        include Nylas::HttpClient
        attr_accessor :api_server

        def api_uri
          "https://api.nylas.com"
        end

        def auth_header(api_key)
          { "Authorization" => "Bearer #{api_key}" }
        end
      end.new

      large_attachment = {
        size: 4 * 1024 * 1024,
        content: mock_file,
        filename: "large_file.txt",
        content_type: "text/plain"
      }
      request_body = {
        to: [{ email: "test@example.com" }],
        subject: "Test email with large attachment",
        body: "This is a test email",
        attachments: [large_attachment]
      }

      allow(mock_file).to receive(:read).and_return("file content")
      allow(File).to receive(:size).and_return(large_attachment[:size])

      # This should return a payload with symbol keys (including :multipart => true) from transform_keys
      payload, _opened_files = described_class.handle_message_payload(request_body)

      # Before the fix, this would fail because build_request only checked for string "multipart"
      # After the fix, it should properly handle the symbol :multipart key
      expect do
        request = test_client.send(:build_request,
                                   method: :post,
                                   path: "/v3/grants/test/messages/send",
                                   payload: payload,
                                   api_key: "test-key")

        # The request should be properly formatted for multipart
        expect(request[:payload]).not_to include(:multipart) # Should be removed
        expect(request[:payload]).not_to include("multipart") # Should be removed
        expect(request[:headers]).not_to include("Content-type") # Should NOT be JSON
      end.not_to raise_error
    end
  end
end
