#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Sending attachments from a stream (no local file on disk)
#
# When content comes from a stream (network, database, etc.), read it into a
# string and pass it to the SDK. You do not need a local file path.
#
#   stream = some_source.read  # IO, StringIO, HTTP response body, etc.
#   attachment = { filename: "doc.pdf", content_type: "application/pdf", size: stream.bytesize, content: stream }
#
# Environment variables:
#   NYLAS_API_KEY     - Your Nylas API key
#   NYLAS_GRANT_ID    - Grant ID (connected account)
#   NYLAS_TEST_EMAIL  - Recipient email
#
# Optional: NYLAS_API_URI (default: https://api.us.nylas.com)
# Optional: LARGE_ATTACHMENT=1 for >3MB (multipart path)

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "nylas"

def load_env
  env_file = File.expand_path("../.env", __dir__)
  return unless File.exist?(env_file)

  File.readlines(env_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    ENV[key] = value&.gsub(/\A['"]|['"]\z/, "") if key && value
  end
end

def attachment_from_stream(io, filename:, content_type:)
  content = io.read
  io.close if io.respond_to?(:close)

  {
    filename: filename,
    content_type: content_type,
    size: content.bytesize,
    content: content
  }
end

def main
  load_env

  api_key = ENV["NYLAS_API_KEY"]
  grant_id = ENV["NYLAS_GRANT_ID"]
  recipient = ENV["NYLAS_TEST_EMAIL"]

  raise "Set NYLAS_API_KEY, NYLAS_GRANT_ID, NYLAS_TEST_EMAIL" unless api_key && grant_id && recipient

  nylas = Nylas::Client.new(
    api_key: api_key,
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )

  use_large = ENV["LARGE_ATTACHMENT"] == "1"

  if use_large
    stream = StringIO.new("%PDF-1.4\n" + ("x" * (4 * 1024 * 1024 - 32)))
    attachment = attachment_from_stream(stream, filename: "report.pdf", content_type: "application/pdf")
    puts "Using large attachment (>3MB) - multipart form-data path"
  else
    stream = StringIO.new("%PDF-1.4 simulated content " + ("x" * 1024))
    attachment = attachment_from_stream(stream, filename: "report.pdf", content_type: "application/pdf")
    puts "Using small attachment (<3MB) - JSON base64 path"
  end

  puts "Sending email with streamed attachment..."
  puts "  Attachment: #{attachment[:filename]} (#{attachment[:size]} bytes)"
  puts "  No local file - content from stream"

  response, request_id = nylas.messages.send(
    identifier: grant_id,
    request_body: {
      subject: "Report",
      body: "Attached document from stream.",
      to: [{ email: recipient }],
      attachments: [attachment]
    }
  )

  puts "Sent. Message ID: #{response[:id]}, Request ID: #{request_id}"
end

main if __FILE__ == $PROGRAM_NAME
