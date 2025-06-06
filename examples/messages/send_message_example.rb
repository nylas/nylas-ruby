#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating basic message sending functionality in the Nylas Ruby SDK
#
# This example shows how to:
# 1. Send a simple text message
# 2. Send a message with CC and BCC recipients
# 3. Send a message with HTML content
# 4. Handle send responses and errors
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
end

def send_simple_message(nylas, grant_id, recipient_email)
  puts "\n=== Sending Simple Text Message ==="
  
  begin
    request_body = {
      subject: "Simple Test Message - Nylas Ruby SDK",
      to: [{ email: recipient_email }],
      body: "Hello! This is a simple test message sent using the Nylas Ruby SDK.\n\nSent at: #{Time.now}"
    }
    
    puts "- Sending simple message..."
    puts "- Recipient: #{recipient_email}"
    puts "- Subject: #{request_body[:subject]}"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    
    response
  rescue => e
    puts "❌ Failed to send simple message: #{e.message}"
    puts "- Error class: #{e.class}"
    raise
  end
end

def send_message_with_multiple_recipients(nylas, grant_id, recipient_email)
  puts "\n=== Sending Message with CC and BCC ==="
  
  begin
    request_body = {
      subject: "Test Message with Multiple Recipients - Nylas Ruby SDK",
      to: [{ email: recipient_email }],
      cc: [{ email: recipient_email, name: "CC Recipient" }],
      bcc: [{ email: recipient_email, name: "BCC Recipient" }],
      body: "This message demonstrates sending to multiple recipients.\n\n- TO: Primary recipient\n- CC: Carbon copy\n- BCC: Blind carbon copy\n\nSent at: #{Time.now}"
    }
    
    puts "- Sending message with multiple recipients..."
    puts "- TO: #{recipient_email}"
    puts "- CC: #{recipient_email} (CC Recipient)"
    puts "- BCC: #{recipient_email} (BCC Recipient)"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    puts "✅ Message with multiple recipients sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    
    response
  rescue => e
    puts "❌ Failed to send message with multiple recipients: #{e.message}"
    puts "- Error class: #{e.class}"
    raise
  end
end

def send_html_message(nylas, grant_id, recipient_email)
  puts "\n=== Sending HTML Message ==="
  
  begin
    html_content = <<~HTML
      <html>
        <body>
          <h1>HTML Test Message</h1>
          <p>This is a <strong>rich HTML</strong> message sent using the Nylas Ruby SDK.</p>
          <ul>
            <li>✅ HTML formatting works</li>
            <li>🎨 Rich content supported</li>
            <li>📧 Email delivery confirmed</li>
          </ul>
          <p><em>Sent at: #{Time.now}</em></p>
        </body>
      </html>
    HTML
    
    request_body = {
      subject: "HTML Test Message - Nylas Ruby SDK",
      to: [{ email: recipient_email }],
      body: html_content,
      # Also include a plain text version
      reply_to: [{ email: recipient_email }]
    }
    
    puts "- Sending HTML message..."
    puts "- Recipient: #{recipient_email}"
    puts "- Content: Rich HTML with formatting"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    puts "✅ HTML message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    
    response
  rescue => e
    puts "❌ Failed to send HTML message: #{e.message}"
    puts "- Error class: #{e.class}"
    raise
  end
end

def main
  # Load .env file if it exists
  load_env_file
  
  # Check for required environment variables
  api_key = ENV["NYLAS_API_KEY"]
  grant_id = ENV["NYLAS_GRANT_ID"] 
  test_email = ENV["NYLAS_TEST_EMAIL"]
  
  raise "NYLAS_API_KEY environment variable is not set" unless api_key
  raise "NYLAS_GRANT_ID environment variable is not set" unless grant_id
  raise "NYLAS_TEST_EMAIL environment variable is not set" unless test_email
  
  puts "=== Nylas Send Message Example ==="
  puts "Using API key: #{api_key[0..4]}..."
  puts "Using grant ID: #{grant_id[0..8]}..."
  puts "Test email recipient: #{test_email}"
  
  # Initialize the Nylas client
  nylas = Nylas::Client.new(
    api_key: api_key,
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )
  
  begin
    # Test 1: Send simple message
    simple_response = send_simple_message(nylas, grant_id, test_email)
    
    # Test 2: Send message with multiple recipients
    multi_response = send_message_with_multiple_recipients(nylas, grant_id, test_email)
    
    # Test 3: Send HTML message
    html_response = send_html_message(nylas, grant_id, test_email)
    
    puts "\n=== Summary ==="
    puts "✅ All message sending tests completed successfully!"
    puts "- Simple message ID: #{simple_response[:id]}"
    puts "- Multi-recipient message ID: #{multi_response[:id]}"
    puts "- HTML message ID: #{html_response[:id]}"
    puts "- All messages sent to: #{test_email}"
    
  rescue => e
    puts "\n❌ Example failed: #{e.message}"
    puts "- #{e.backtrace.first}"
    exit 1
  end
  
  puts "\n🎉 Send message example completed successfully!"
  puts "This confirms that the Nylas Ruby SDK can:"
  puts "- Send simple text messages"
  puts "- Handle multiple recipients (TO, CC, BCC)"
  puts "- Send rich HTML content"
  puts "- Process responses and handle errors"
end

if __FILE__ == $0
  main
end 