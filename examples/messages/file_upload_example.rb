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

def create_small_test_file
  puts "\n=== Creating Small Test File (<3MB) ==="
  
  begin
    # Create a 1MB test file
    content = "A" * (1024 * 1024)  # 1MB of 'A' characters
    
    temp_file = Tempfile.new(['small_test', '.txt'])
    temp_file.write(content)
    temp_file.rewind
    
    puts "- Created test file: #{temp_file.path}"
    puts "- File size: #{File.size(temp_file.path)} bytes (#{File.size(temp_file.path) / (1024.0 * 1024).round(2)} MB)"
    puts "- This will be sent as JSON with base64 encoding"
    
    temp_file
  rescue => e
    log_detailed_error(e, "creating small test file")
    raise
  end
end

def find_small_pdf_test_file
  puts "\n=== Finding PDF Test File ==="
  
  begin
    pdf_file_path = File.expand_path("small_pdf_test_file.pdf", __dir__)
    unless File.exist?(pdf_file_path)
      raise "PDF test file not found at #{pdf_file_path}. Please create a PDF file for testing."
    end

    puts "- Found PDF test file: #{pdf_file_path}"
    puts "- File size: #{File.size(pdf_file_path)} bytes (#{File.size(pdf_file_path) / (1024.0 * 1024).round(2)} MB)"
    puts "- This will be sent as multipart form data"
    
    pdf_file_path
  rescue => e
    log_detailed_error(e, "finding small PDF test file")
    raise
  end
end

def find_large_pdf_test_file
  puts "\n=== Finding Large PDF Test File ==="
  
  begin
    pdf_file_path = File.expand_path("large_pdf_test_file.pdf", __dir__)
    unless File.exist?(pdf_file_path)
      raise "PDF test file not found at #{pdf_file_path}. Please create a PDF file for testing."
    end
    
    puts "- Found large PDF test file: #{pdf_file_path}"
    puts "- File size: #{File.size(pdf_file_path)} bytes (#{File.size(pdf_file_path) / (1024.0 * 1024).round(2)} MB)"
    puts "- This will be sent as multipart form data"
    
    pdf_file_path
  rescue => e
    log_detailed_error(e, "finding large PDF test file")
    raise
  end
end

def find_large_jpg_test_file
  puts "\n=== Finding Large JPG Test File ==="
  
  begin
    jpg_file_path = File.expand_path("large_jpg_test_file.jpg", __dir__)
    unless File.exist?(jpg_file_path)
      raise "JPG test file not found at #{jpg_file_path}. Please create a JPG file for testing."
    end

    puts "- Found large JPG test file: #{jpg_file_path}"
    puts "- File size: #{File.size(jpg_file_path)} bytes (#{File.size(jpg_file_path) / (1024.0 * 1024).round(2)} MB)"
    puts "- This will be sent as multipart form data"

    jpg_file_path
  rescue => e 
    log_detailed_error(e, "finding large JPG test file")
    raise
  end
end

def find_or_create_large_test_file
  puts "\n=== Finding Large Test File (>3MB) ==="
  
  begin
    # Look for an existing large file, or create one if needed
    large_file_path = File.expand_path("large_test_file.txt", __dir__)
    
    unless File.exist?(large_file_path) && File.size(large_file_path) > 3 * 1024 * 1024
      puts "- Creating 5MB test file on disk..."
      content = "B" * (5 * 1024 * 1024)  # 5MB of 'B' characters
      File.write(large_file_path, content)
      puts "- Created permanent test file: #{large_file_path}"
    else
      puts "- Found existing test file: #{large_file_path}"
    end
    
    puts "- File size: #{File.size(large_file_path)} bytes (#{File.size(large_file_path) / (1024.0 * 1024).round(2)} MB)"
    puts "- This will be sent as multipart form data"
    
    large_file_path
  rescue => e
    log_detailed_error(e, "finding or creating large test file")
    raise
  end
end

def send_message_with_small_attachment(nylas, grant_id, recipient_email, test_file)
  puts "\n=== Sending Message with Small Attachment ==="
  
  begin
    puts "- Building file attachment for: #{test_file.path}"
    
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file.path)
    puts "- File attachment built successfully"
    puts "- Attachment keys: #{file_attachment.keys}"
    
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
    puts "- Request body keys: #{request_body.keys}"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    puts "- Response keys: #{response.keys}"
    
    response
  rescue => e
    log_detailed_error(e, "sending message with small attachment")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file.path}"
    puts "- File size: #{File.size(test_file.path)} bytes" if File.exist?(test_file.path)
    raise
  end
end

def send_message_with_large_attachment(nylas, grant_id, recipient_email, test_file_path)
  puts "\n=== Sending Message with Large Attachment ==="
  
  begin
    puts "- Building file attachment for: #{test_file_path}"
    
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file_path)
    puts "- File attachment built successfully"
    puts "- Attachment keys: #{file_attachment.keys}"
    
    request_body = {
      subject: "Test Email with Large Attachment (>3MB) - HTTParty Migration Test",
      to: [{ email: recipient_email }],
      body: "This is a test email with a large attachment (>3MB) to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
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
    
    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    puts "- Response keys: #{response.keys}"
    
    response
  rescue => e
    log_detailed_error(e, "sending message with large attachment")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file_path}"
    puts "- File size: #{File.size(test_file_path)} bytes" if File.exist?(test_file_path)
    raise
  end
end

def send_message_with_small_pdf_attachment(nylas, grant_id, recipient_email, test_file_path)
  puts "\n=== Sending Message with PDF Attachment ==="
  
  begin
    puts "- Building PDF file attachment for: #{test_file_path}"
    
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file_path)
    puts "- PDF file attachment built successfully"
    puts "- Attachment keys: #{file_attachment.keys}"

    request_body = {
      subject: "Test Email with PDF Attachment",
      to: [{ email: recipient_email }],
      body: "This is a test email with a PDF attachment to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }
    
    puts "- Sending message with PDF attachment..."
    puts "- Recipient: #{recipient_email}"
    puts "- Attachment size: #{File.size(test_file_path)} bytes"
    puts "- Expected handling: Multipart form data"
    puts "- Request body keys: #{request_body.keys}"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )

    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    puts "- Response keys: #{response.keys}"

    response
  rescue => e
    log_detailed_error(e, "sending message with PDF attachment")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file_path}"
    puts "- File size: #{File.size(test_file_path)} bytes" if File.exist?(test_file_path)
    raise
  end
end

def send_message_with_large_pdf_attachment(nylas, grant_id, recipient_email, test_file_path)
  puts "\n=== Sending Message with Large PDF Attachment ==="
  
  begin
    puts "- Building large PDF file attachment for: #{test_file_path}"
    
    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file_path)
    puts "- Large PDF file attachment built successfully"
    puts "- Attachment keys: #{file_attachment.keys}"

    request_body = {
      subject: "Test Email with Large PDF Attachment",
      to: [{ email: recipient_email }],
      body: "This is a test email with a large PDF attachment to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }

    puts "- Sending message with large PDF attachment..."
    puts "- Recipient: #{recipient_email}"
    puts "- Attachment size: #{File.size(test_file_path)} bytes"
    puts "- Expected handling: Multipart form data"
    puts "- Request body keys: #{request_body.keys}"

    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )

    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    puts "- Response keys: #{response.keys}"

    response
  rescue => e
    log_detailed_error(e, "sending message with large PDF attachment")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file_path}"
    puts "- File size: #{File.size(test_file_path)} bytes" if File.exist?(test_file_path)
    raise
  end
end

def send_message_with_large_jpg_attachment(nylas, grant_id, recipient_email, test_file_path)
  puts "\n=== Sending Message with Large JPG Attachment ==="
  
  begin
    puts "- Building large JPG file attachment for: #{test_file_path}"

    # Build the file attachment
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file_path)
    puts "- Large JPG file attachment built successfully"
    puts "- Attachment keys: #{file_attachment.keys}"

    request_body = {
      subject: "Test Email with Large JPG Attachment",
      to: [{ email: recipient_email }],
      body: "This is a test email with a large JPG attachment to verify the HTTParty migration works correctly.\n\nFile size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }

    puts "- Sending message with large JPG attachment..."
    puts "- Recipient: #{recipient_email}"
    puts "- Attachment size: #{File.size(test_file_path)} bytes"
    puts "- Expected handling: Multipart form data"
    puts "- Request body keys: #{request_body.keys}"
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    puts "✅ Message sent successfully!"
    puts "- Message ID: #{response[:id]}" 
    puts "- Request ID: #{request_id}"
    puts "- Grant ID: #{response[:grant_id]}"
    puts "- Response keys: #{response.keys}"

    response
  rescue => e
    log_detailed_error(e, "sending message with large JPG attachment")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file_path}"
    puts "- File size: #{File.size(test_file_path)} bytes" if File.exist?(test_file_path)
    raise
  end
end

def demonstrate_file_utils_handling
  puts "\n=== Demonstrating File Handling Logic ==="
  
  begin
    # Create temporary files to test the file handling logic
    small_file = create_small_test_file
    large_file_path = find_or_create_large_test_file

    begin
      puts "- Testing file attachment builders..."
      
      # Test small file handling
      small_attachment = Nylas::FileUtils.attach_file_request_builder(small_file.path)
      puts "- Small file attachment structure: #{small_attachment.keys}"
      puts "- Small file attachment content type: #{small_attachment[:content_type]}" if small_attachment[:content_type]
      
      # Test large file handling  
      large_attachment = Nylas::FileUtils.attach_file_request_builder(large_file_path)
      puts "- Large file attachment structure: #{large_attachment.keys}"
      puts "- Large file attachment content type: #{large_attachment[:content_type]}" if large_attachment[:content_type]
      
      # Demonstrate the SDK's file size handling
      small_payload = {
        subject: "test",
        attachments: [small_attachment]
      }
      
      large_payload = {
        subject: "test", 
        attachments: [large_attachment]
      }
      
      puts "- Testing payload handling methods..."
      
      # Show how the SDK determines handling method
      small_handling, small_files = Nylas::FileUtils.handle_message_payload(small_payload)
      large_handling, large_files = Nylas::FileUtils.handle_message_payload(large_payload)
      
      puts "- Small file handling method: #{small_handling['multipart'] ? 'Form Data' : 'JSON'}"
      puts "- Small files detected: #{small_files ? small_files.length : 0}"
      puts "- Large file handling method: #{large_handling['multipart'] ? 'Form Data' : 'JSON'}"
      puts "- Large files detected: #{large_files ? large_files.length : 0}"
      
    ensure
      small_file.close
      small_file.unlink
      puts "- Cleaned up small test file"
      # Note: We keep the large file on disk for future use
    end
  rescue => e
    log_detailed_error(e, "demonstrating file utils handling")
    raise
  end
end

def test_utf8_encoding_bug_with_large_attachment(nylas, grant_id, recipient_email, test_file_path)
  puts "\n=== Testing UTF-8 Encoding Bug with Large Attachment ==="
  puts "🐛 This test reproduces the HTTParty UTF-8 encoding bug"
  puts "    when sending multipart/form-data requests with non-ASCII characters"
  
  begin
    puts "- Building file attachment for: #{test_file_path}"
    
    # Build the file attachment to force multipart handling
    file_attachment = Nylas::FileUtils.attach_file_request_builder(test_file_path)
    puts "- File attachment built successfully"
    
    # Create a request body with UTF-8 characters that should trigger the bug
    request_body = {
      subject: "UTF-8 Test: Ñylas 🚀 Tëst with Émojis and Spëcial Charactërs",
      to: [{ email: recipient_email, name: "Tëst Récipient 👤" }],
      body: "This message contains UTF-8 characters: ñ, é, ü, 中文, العربية, русский, 日本語, 한국어\n\n" +
            "With emojis: 🚀 🌟 ✨ 💫 🎉 🎊 🎯 🔥 💯 ⚡\n\n" +
            "Special characters: àáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ\n\n" +
            "This should trigger the UTF-8 encoding bug in HTTParty when combined with large attachments.\n\n" +
            "File size: #{File.size(test_file_path)} bytes\nSent at: #{Time.now}",
      attachments: [file_attachment]
    }
    
    puts "- Message contains UTF-8 characters in subject and body"
    puts "- Subject: #{request_body[:subject]}"
    puts "- Recipient name: #{request_body[:to][0][:name]}"
    puts "- Attachment size: #{File.size(test_file_path)} bytes (forces multipart)"
    puts "- Expected behavior: HTTParty should raise ArgumentError about invalid byte sequence"
    
    puts "- Attempting to send message (this should fail with UTF-8 encoding error)..."
    
    response, request_id = nylas.messages.send(
      identifier: grant_id,
      request_body: request_body
    )
    
    # If we reach here, the bug might be fixed or the test conditions weren't met
    puts "⚠️  UNEXPECTED: Message sent successfully!"
    puts "- Message ID: #{response[:id]}"
    puts "- Request ID: #{request_id}"
    puts "- This suggests the UTF-8 encoding bug may have been fixed"
    puts "- Or the test conditions didn't trigger multipart handling"
    
    response
  rescue ArgumentError => e
    if e.message.include?("invalid byte sequence") || e.message.include?("UTF-8")
      puts "✅ BUG REPRODUCED: UTF-8 encoding error caught as expected!"
      puts "- Error message: #{e.message}"
      puts "- This confirms the bug exists in HTTParty multipart handling"
      puts "- The issue is that UTF-8 encoded JSON message part is incompatible"
      puts "  with HTTParty's expectation that all multipart fields are ASCII-8BIT/BINARY"
      
      # Re-raise to show the full stack trace
      raise e
    else
      puts "❓ Different ArgumentError occurred:"
      puts "- Error message: #{e.message}"
      raise e
    end
  rescue => e
    log_detailed_error(e, "UTF-8 encoding bug test")
    puts "- Grant ID used: #{grant_id}"
    puts "- Recipient: #{recipient_email}"
    puts "- File path: #{test_file_path}"
    puts "- File size: #{File.size(test_file_path)} bytes" if File.exist?(test_file_path)
    puts "- This error may or may not be the expected UTF-8 encoding bug"
    raise
  end
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
    demonstrate_file_utils_handling
    
    # Create test files
    puts "- Creating and finding test files..."
    small_file = create_small_test_file
    large_file_path = find_or_create_large_test_file
    small_pdf_file_path = find_small_pdf_test_file
    large_pdf_file_path = find_large_pdf_test_file
    large_jpg_file_path = find_large_jpg_test_file
    
    begin
      # Test 1: Send message with small attachment
      small_response = send_message_with_small_attachment(nylas, grant_id, test_email, small_file)
      
      # Test 2: Send message with large attachment  
      large_response = send_message_with_large_attachment(nylas, grant_id, test_email, large_file_path)
      
      # Test 3: Send message with PDF attachment
      pdf_response = send_message_with_small_pdf_attachment(nylas, grant_id, test_email, small_pdf_file_path)
      
      # Test 4: Send message with large PDF attachment
      large_pdf_response = send_message_with_large_pdf_attachment(nylas, grant_id, test_email, large_pdf_file_path)
      
      # Test 5: Send message with large JPG attachment
      large_jpg_response = send_message_with_large_jpg_attachment(nylas, grant_id, test_email, large_jpg_file_path)
      
      # Test 5: Test UTF-8 encoding bug with large attachment
      puts "\n⚠️  WARNING: The next test is expected to FAIL and demonstrate a bug"
      puts "    If it succeeds, the bug may have been fixed!"
      begin
        utf8_bug_response = test_utf8_encoding_bug_with_large_attachment(nylas, grant_id, test_email, large_file_path)
        puts "✅ UTF-8 test completed (unexpectedly successful)"
      rescue ArgumentError => e
        if e.message.include?("invalid byte sequence") || e.message.include?("UTF-8")
          puts "✅ UTF-8 encoding bug successfully reproduced!"
          puts "    This confirms the reported bug exists."
        else
          puts "❌ Different ArgumentError occurred during UTF-8 test"
          raise e
        end
      rescue => e
        puts "❌ Unexpected error during UTF-8 test"
        raise e
      end
      
      puts "\n=== Summary ==="
      puts "✅ File upload tests completed!"
      puts "- Small file message ID: #{small_response[:id]}"
      puts "- Large file message ID: #{large_response[:id]}"
      puts "- PDF message ID: #{pdf_response[:id]}"
      puts "- Large PDF message ID: #{large_pdf_response[:id]}"
      puts "- Large JPG message ID: #{large_jpg_response[:id]}"
      puts "- UTF-8 encoding bug test: See results above"
      puts "- HTTParty migration verified for supported file handling methods"
      
    ensure
      # Clean up temporary small file only
      if small_file
        small_file.close
        small_file.unlink
        puts "\n🧹 Cleaned up temporary small file (large file kept on disk for reuse)"
      end
    end
    
  rescue => e
    log_detailed_error(e, "main execution")
    puts "\n💡 TROUBLESHOOTING HINTS:"
    puts "- Check that all environment variables are set correctly"
    puts "- Verify your API key has the correct permissions"
    puts "- Ensure the grant ID is valid and active"
    puts "- Check that the test email address is valid"
    puts "- Verify network connectivity to the Nylas API"
    puts "- Make sure test PDF files exist in the examples/messages directory"
    exit 1
  end
  
  puts "\n🎉 File upload example completed!"
  puts "This example tests the HTTParty migration and includes:"
  puts "- Small files (<3MB): JSON with base64 encoding"
  puts "- Large files (>3MB): Multipart form data"
  puts "- File attachment building and processing"
  puts "- HTTP request execution with different payload types"
  puts "- UTF-8 encoding bug reproduction test (may fail as expected)"
end

if __FILE__ == $0
  main
end 