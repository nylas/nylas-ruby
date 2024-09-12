# frozen_string_literal: true

require "mime/types"

module Nylas
  # A collection of file-related utilities.
  module FileUtils
    # The maximum size of an attachment that can be sent using json
    FORM_DATA_ATTACHMENT_SIZE = 3 * 1024 * 1024

    # Build a form request for the API.
    # @param request_body The values to create the message with.
    # @return The form data to send to the API and the opened files.
    # @!visibility private
    def self.build_form_request(request_body)
      attachments = request_body[:attachments] || request_body["attachments"] || []
      serializable_body = request_body.reject { |key, _| [:attachments, "attachments"].include?(key) }
      request_body_copy = Marshal.load(Marshal.dump(serializable_body))

      # RestClient will not send a multipart request if there are no attachments
      return [request_body_copy, []] if attachments.empty?

      # Prepare the data to return
      message_payload = request_body_copy.to_json

      form_data = {}
      opened_files = []

      attachments.each_with_index do |attachment, index|
        file = attachment[:content] || attachment["content"]
        if file.respond_to?(:closed?) && file.closed?
          unless attachment[:file_path]
            raise ArgumentError, "The file at index #{index} is closed and no file_path was provided."
          end

          file = File.open(attachment[:file_path], "rb")
        end

        form_data.merge!({ "file#{index}" => file })
        opened_files << file
      end

      form_data.merge!({ "multipart" => true, "message" => message_payload })

      [form_data, opened_files]
    end

    # Build a json attachment request for the API.
    # @param attachments The attachments to send with the message. Can be a file object or a base64 string.
    # @return The properly-formatted json data to send to the API and the opened files.
    # @!visibility private
    def self.build_json_request(attachments)
      opened_files = []

      attachments.each_with_index do |attachment, _index|
        current_attachment = attachment[:content]
        next unless current_attachment

        if current_attachment.respond_to?(:read)
          attachment[:content] = Base64.strict_encode64(current_attachment.read)
          opened_files << current_attachment
        else
          attachment[:content] = current_attachment
        end
      end

      [attachments, opened_files]
    end

    # Handle encoding the message payload.
    # @param request_body The values to create the message with.
    # @return The encoded message payload and any opened files.
    # @!visibility private
    def self.handle_message_payload(request_body)
      payload = request_body.transform_keys(&:to_sym)
      opened_files = []

      # Use form data only if the attachment size is greater than 3mb
      attachments = payload[:attachments]
      attachment_size = attachments&.sum { |attachment| attachment[:size] || 0 } || 0

      # Handle the attachment encoding depending on the size
      if attachment_size >= FORM_DATA_ATTACHMENT_SIZE
        payload, opened_files = build_form_request(request_body)
      else
        payload[:attachments], opened_files = build_json_request(attachments) unless attachments.nil?
      end

      [payload, opened_files]
    end

    # Build the request to attach a file to a message/draft object.
    # @param file_path [String] The path to the file to attach.
    # @return [Hash] The request that will attach the file to the message/draft
    def self.attach_file_request_builder(file_path)
      filename = File.basename(file_path)
      content_type = MIME::Types.type_for(file_path)
      content_type = if !content_type.nil? && !content_type.empty?
                       content_type.first.to_s
                     else
                       "application/octet-stream"
                     end
      size = File.size(file_path)
      content = File.new(file_path, "rb")

      {
        filename: filename,
        content_type: content_type,
        size: size,
        content: content,
        file_path: file_path
      }
    end
  end
end
