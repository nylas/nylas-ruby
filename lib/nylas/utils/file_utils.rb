# frozen_string_literal: true

module Nylas
  # A collection of file-related utilities.
  module FileUtils
    # Build a form request for the API.
    # @param request_body The values to create the message with.
    # @return The form data to send to the API and the opened files.
    # @!visibility private
    def self.build_form_request(request_body)
      attachments = request_body.delete(:attachments) || request_body.delete("attachments") || []
      message_payload = request_body.to_json

      # Prepare the data to return
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
  end
end
