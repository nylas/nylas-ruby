#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating file upload functionality in the Nylas Ruby SDK
# Tests both small (<3MB) and large (>3MB) file handling with the new HTTParty implementation
#
# This example shows how to:
# 1. Send messages with small attachments (<3MB) - handled as JSON with base64 encoding
# 2. Send messages with large attachments (>3MB) - handled as multipart form data
# 3. Create test files of appropriate sizes for demonstration
# 4. Handle file upload errors and responses
#
# Prerequisites:
# - Ruby 3.0 or later
# - A Nylas API key
# - A grant ID (connected email account)
# - A test email address to send to
#
# Environment variables needed:
# export NYLAS_API_KEY="your_api_key"
# export NYLAS_GRANT_ID="your_grant_id"
# export NYLAS_TEST_EMAIL="test@example.com"  # Email address to send test messages to
# export NYLAS_API_URI="https://api.us.nylas.com"  # Optional
#
# Alternatively, create a .env file in the examples directory with:
# NYLAS_API_KEY=your_api_key
# NYLAS_GRANT_ID=your_grant_id
# NYLAS_TEST_EMAIL=test@example.com
# NYLAS_API_URI=https://api.us.nylas.com

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require "nylas"
require "json"
require "tempfile"

# Enhanced error logging helper
def log_detailed_error(error, context = "")
  puts "\n❌ ERROR DETAILS #{context.empty? ? '' : "- #{context}"}"
  puts "=" * 60
  puts "Error Class: #{error.class}"
  puts "Error Message: #{error.message}"
  
  if error.respond_to?(:response) && error.response
    puts "HTTP Response Code: #{error.response.code}" if error.response.respond_to?(:code)
    puts "HTTP Response Body: #{error.response.body}" if error.response.respond_to?(:body)
    puts "HTTP Response Headers: #{error.response.headers}" if error.response.respond_to?(:headers)
  end
  
  if error.respond_to?(:request_id) && error.request_id
    puts "Request ID: #{error.request_id}"
  end
  
  puts "Full Stack Trace:"
  puts error.backtrace.join("\n")
  puts "=" * 60
end

# Simple .env file loader
def load_env_file
  env_file = File.expand_path('../.env', __dir__)
  return unless File.exist?(env_file)
  
  puts "Loading environment variables from .env file..."
  File.readlines(env_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    
    key, value = line.split('=', 2)
    next unless key && value
    
    # Remove quotes if present
    value = value.gsub(/\A['"]|['"]\z/, '')
    ENV[key] = value
  end
rescue => e
  log_detailed_error(e, "loading .env file")
  raise
end

# Def send message with small attachment
def send_message_with_attachment(nylas, grant_id, recipient_email, test_file_path, content_type)
  # load the file and read it's contents
  file_contents = File.read(test_file_path)

  # manually build file_attachment
  file_attachment = {
    filename: File.basename(test_file_path),
    content_type: content_type,
    content: file_contents,
    size: File.size(test_file_path)
  }

  request_body = {
    subject: "Test Email with Attachment",
    to: [{ email: recipient_email }],
    body: "This is a test email with a attachment.\n\nFile size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
    attachments: [file_attachment]
  }
  
  puts "- Sending message with large attachment..."
  puts "- Recipient: #{recipient_email}"
  puts "- Attachment size: #{File.size(test_file_path)} bytes"
  puts "- Expected handling: Multipart form data"
  puts "- Request body keys: #{request_body.keys}"
  
  response, request_id = nylas.messages.send(
    identifier: grant_id,
    request_body: request_body
  )

  puts "Response: #{response}"
  puts "Request ID: #{request_id}"
  puts "Grant ID: #{response[:grant_id]}"
  puts "Message ID: #{response[:id]}"
  puts "Message Subject: #{response[:subject]}"
  puts "Message Body: #{response[:body]}"
  
end

def main
  puts "=== Nylas File Upload Example - HTTParty Migration Test ==="
  
  begin
    # Load .env file if it exists
    load_env_file
    
    # Check for required environment variables
    api_key = ENV["NYLAS_API_KEY"]
    grant_id = ENV["NYLAS_GRANT_ID"] 
    test_email = ENV["NYLAS_TEST_EMAIL"]
    
    puts "- Checking environment variables..."
    raise "NYLAS_API_KEY environment variable is not set" unless api_key
    raise "NYLAS_GRANT_ID environment variable is not set" unless grant_id
    raise "NYLAS_TEST_EMAIL environment variable is not set" unless test_email
    
    puts "Using API key: #{api_key[0..4]}..."
    puts "Using grant ID: #{grant_id[0..8]}..."
    puts "Test email recipient: #{test_email}"
    puts "API URI: #{ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"}"
    
    # Initialize the Nylas client
    puts "- Initializing Nylas client..."
    nylas = Nylas::Client.new(
      api_key: api_key,
      api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
    )
    puts "- Nylas client initialized successfully"
    
    # Demonstrate file handling logic
    jpg_file_path = File.expand_path("large_jpg_test_file.jpg", __dir__)
    unless File.exist?(jpg_file_path)
      raise "JPG test file not found at #{jpg_file_path}. Please create a JPG file for testing."
    end
    send_message_with_attachment(nylas, grant_id, test_email, jpg_file_path, "image/jpeg")

    puts "\n=== File Upload Example Completed Successfully ==="
  rescue => e
    log_detailed_error(e, "main method")
    raise
  end
end

main