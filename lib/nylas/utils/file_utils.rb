# frozen_string_literal: true

require "mime/types"

module Nylas
  # A collection of file-related utilities.
  module FileUtils
    # Build a form request for the API.
    # @param request_body The values to create the message with.
    # @return The form data to send to the API and the opened files.
    # @!visibility private
    def self.build_form_request(request_body)
      attachments = request_body.delete(:attachments) || request_body.delete("attachments") || []

      # RestClient will not send a multipart request if there are no attachments
      # so we need to return the message payload to be used as a json payload
      return [request_body, []] if attachments.empty?

      # Prepare the data to return
      message_payload = request_body.to_json

      form_data = {}
      opened_files = []

      attachments.each_with_index do |attachment, index|
        file = attachment[:content] || attachment["content"]
        form_data.merge!({ "file#{index}" => file })
        opened_files << file
      end

      form_data.merge!({ "multipart" => true, "message" => message_payload })

      [form_data, opened_files]
    end

    # Build the request to attach a file to a message/draft object.
    # @param file_path [String] The path to the file to attach.
    # @return [Hash] The request that will attach the file to the message/draft
    def self.attach_file_request_builder(file_path)
      filename = File.basename(file_path)
      content_type = MIME::Types.type_for(file_path).first.to_s
      content_type = "application/octet-stream" if content_type.empty?
      size = File.size(file_path)
      content = File.new(file_path, "rb")

      {
        filename: filename,
        content_type: content_type,
        size: size,
        content: content
      }
    end
  end
end
