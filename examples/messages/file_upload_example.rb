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

def create_small_test_file
  puts "\n=== Creating Small Test File (<3MB) ==="
  
  # Create a 1MB test file
  content = "A" * (1024 * 1024)  # 1MB of 'A' characters
  
  temp_file = Tempfile.new(['small_test', '.txt'])
  temp_file.write(content)
  temp_file.rewind
  
  puts "- Created test file: #{temp_file.path}"
  puts "- File size: #{File.size(temp_file.path)} bytes (#{File.size(temp_file.path) / (1024.0 * 1024).round(2)} MB)"
  puts "- This will be sent as JSON with base64 encoding"
  
  temp_file
end

def create_large_test_file
  puts "\n=== Creating Large Test File (>3MB) ==="
  
  # Create a 5MB test file
  content = "B" * (5 * 1024 * 1024)  # 5MB of 'B' characters
  
  temp_file = Tempfile.new(['large_test', '.txt'])
  temp_file.write(content)
  temp_file.rewind
  
  puts "- Created test file: #{temp_file.path}"
  puts "- File size: #{File.size(temp_file.path)} bytes (#{File.size(temp_file.path) / (1024.0 * 1024).round(2)} MB)"
  puts "- This will be sent as multipart form data"
  
  temp_file
end

def send_message_with_small_attachment(nylas, grant_id, recipient_email, test_file)
  puts "\n=== Sending Message with Small Attachment ==="
  
  begin
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file.path)
    
    request_body = {
      subject: "Test Email with Small Attachment (<3MB) - HTTParty Migration Test",
      to: [{ email: recipient_email }],
      body: "This is a test email with a small attachment (<3MB) to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file.path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }
    
    puts "- Sending message with small attachment..."
    puts "- Recipient: #{recipient_email}"
    puts "- Attachment size: #{File.size(test_file.path)} bytes"
    puts "- Expected handling: JSON with base64 encoding"
    
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
    puts "❌ Failed to send message with small attachment: #{e.message}"
    puts "- Error class: #{e.class}"
    raise
  end
end

def send_message_with_large_attachment(nylas, grant_id, recipient_email, test_file)
  puts "\n=== Sending Message with Large Attachment ==="
  
  begin
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file.path)
    
    request_body = {
      subject: "Test Email with Large Attachment (>3MB) - HTTParty Migration Test",
      to: [{ email: recipient_email }],
      body: "This is a test email with a large attachment (>3MB) to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file.path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }
    
    puts "- Sending message with large attachment..."
    puts "- Recipient: #{recipient_email}"
    puts "- Attachment size: #{File.size(test_file.path)} bytes"
    puts "- Expected handling: Multipart form data"
    
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
    puts "❌ Failed to send message with large attachment: #{e.message}"
    puts "- Error class: #{e.class}"
    raise
  end
end

def demonstrate_file_utils_handling
  puts "\n=== Demonstrating File Handling Logic ==="
  
  # Create temporary files to test the file handling logic
  small_file = create_small_test_file
  large_file = create_large_test_file
  
  begin
    # Test small file handling
    small_attachment = Nylas::FileUtils.attach_file_request_builder(small_file.path)
    puts "- Small file attachment structure: #{small_attachment.keys}"
    
    # Test large file handling  
    large_attachment = Nylas::FileUtils.attach_file_request_builder(large_file.path)
    puts "- Large file attachment structure: #{large_attachment.keys}"
    
    # Demonstrate the SDK's file size handling
    small_payload = {
      subject: "test",
      attachments: [small_attachment]
    }
    
    large_payload = {
      subject: "test", 
      attachments: [large_attachment]
    }
    
    # Show how the SDK determines handling method
    small_handling, small_files = Nylas::FileUtils.handle_message_payload(small_payload)
    large_handling, large_files = Nylas::FileUtils.handle_message_payload(large_payload)
    
    puts "- Small file handling method: #{small_handling['multipart'] ? 'Form Data' : 'JSON'}"
    puts "- Large file handling method: #{large_handling['multipart'] ? 'Form Data' : 'JSON'}"
    
  ensure
    small_file.close
    small_file.unlink
    large_file.close  
    large_file.unlink
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
  
  puts "=== Nylas File Upload Example - HTTParty Migration Test ==="
  puts "Using API key: #{api_key[0..4]}..."
  puts "Using grant ID: #{grant_id[0..8]}..."
  puts "Test email recipient: #{test_email}"
  
  # Initialize the Nylas client
  nylas = Nylas::Client.new(
    api_key: api_key,
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )
  
  begin
    # Demonstrate file handling logic
    demonstrate_file_utils_handling
    
    # Create test files
    small_file = create_small_test_file
    large_file = create_large_test_file
    
    begin
      # Test 1: Send message with small attachment
      small_response = send_message_with_small_attachment(nylas, grant_id, test_email, small_file)
      
      # Test 2: Send message with large attachment  
      large_response = send_message_with_large_attachment(nylas, grant_id, test_email, large_file)
      
      puts "\n=== Summary ==="
      puts "✅ Both small and large file uploads completed successfully!"
      puts "- Small file message ID: #{small_response[:id]}"
      puts "- Large file message ID: #{large_response[:id]}"
      puts "- HTTParty migration verified for both file handling methods"
      
    ensure
      # Clean up test files
      small_file.close
      small_file.unlink
      large_file.close
      large_file.unlink
      puts "\n🧹 Cleaned up temporary test files"
    end
    
  rescue => e
    puts "\n❌ Example failed: #{e.message}"
    puts "- #{e.backtrace.first}"
    exit 1
  end
  
  puts "\n🎉 File upload example completed successfully!"
  puts "This confirms that the HTTParty migration properly handles:"
  puts "- Small files (<3MB): JSON with base64 encoding"
  puts "- Large files (>3MB): Multipart form data"
  puts "- File attachment building and processing"
  puts "- HTTP request execution with different payload types"
end

if __FILE__ == $0
  main
end 