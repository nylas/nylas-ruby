#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating the new message fields functionality in the Nylas Ruby SDK
#
# This example shows how to:
# 1. Use MessageFields constants for better code readability
# 2. Retrieve messages with different field options (standard, tracking, headers, raw MIME)
# 3. Access tracking options like opens, thread_replies, links, and labels
# 4. Get raw MIME data for advanced message processing
#
# Prerequisites:
# - Ruby 3.0 or later
# - A Nylas API key
# - A grant ID (connected email account)
#
# Environment variables needed:
# export NYLAS_API_KEY="your_api_key"
# export NYLAS_GRANT_ID="your_grant_id"
# export NYLAS_API_URI="https://api.us.nylas.com"  # Optional
#
# Alternatively, create a .env file in the examples directory with:
# NYLAS_API_KEY=your_api_key
# NYLAS_GRANT_ID=your_grant_id
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

def list_messages_with_standard_fields(nylas, grant_id)
  puts "\n=== Listing Messages with Standard Fields ==="
  
  messages, request_id = nylas.messages.list(
    identifier: grant_id,
    query_params: { 
      fields: Nylas::MessageFields::STANDARD,
      limit: 5 
    }
  )
  
  puts "Found #{messages.length} messages with standard fields"
  if messages.any?
    message = messages.first
    puts "- Sample message ID: #{message[:id]}"
    puts "- Subject: #{message[:subject]}"
    puts "- Has tracking_options: #{message.key?(:tracking_options)}"
    puts "- Has raw_mime: #{message.key?(:raw_mime)}"
  end
  puts "Request ID: #{request_id}"
  
  messages
end

def list_messages_with_tracking_options(nylas, grant_id)
  puts "\n=== Listing Messages with Tracking Options ==="
  
  messages, request_id = nylas.messages.list(
    identifier: grant_id,
    query_params: { 
      fields: Nylas::MessageFields::INCLUDE_TRACKING_OPTIONS,
      limit: 5 
    }
  )
  
  puts "Found #{messages.length} messages with tracking options"
  if messages.any?
    message = messages.first
    puts "- Sample message ID: #{message[:id]}"
    puts "- Subject: #{message[:subject]}"
    
    if message[:tracking_options]
      tracking = message[:tracking_options]
      puts "- Tracking Options:"
      puts "  - Opens tracking: #{tracking[:opens]}"
      puts "  - Thread replies tracking: #{tracking[:thread_replies]}"
      puts "  - Links tracking: #{tracking[:links]}"
      puts "  - Label: #{tracking[:label]}" if tracking[:label]
    else
      puts "- No tracking options available for this message"
    end
  end
  puts "Request ID: #{request_id}"
  
  messages
end

def get_message_with_raw_mime(nylas, grant_id, message_id)
  puts "\n=== Getting Message with Raw MIME Data ==="
  
  message, request_id = nylas.messages.find(
    identifier: grant_id,
    message_id: message_id,
    query_params: { fields: Nylas::MessageFields::RAW_MIME }
  )
  
  puts "Retrieved message with raw MIME data:"
  puts "- Message ID: #{message[:id]}"
  puts "- Grant ID: #{message[:grant_id]}"
  puts "- Object type: #{message[:object]}"
  puts "- Raw MIME length: #{message[:raw_mime]&.length || 0} characters"
  puts "- Raw MIME preview: #{message[:raw_mime]&.slice(0, 50)}..." if message[:raw_mime]
  puts "- Available fields: #{message.keys.sort}"
  puts "Request ID: #{request_id}"
  
  # Note: When using RAW_MIME, only grant_id, object, id, and raw_mime fields are returned
  message
end

def get_message_with_headers(nylas, grant_id, message_id)
  puts "\n=== Getting Message with Headers ==="
  
  message, request_id = nylas.messages.find(
    identifier: grant_id,
    message_id: message_id,
    query_params: { fields: Nylas::MessageFields::INCLUDE_HEADERS }
  )
  
  puts "Retrieved message with headers:"
  puts "- Message ID: #{message[:id]}"
  puts "- Subject: #{message[:subject]}"
  puts "- Has headers: #{message.key?(:headers)}"
  
  if message[:headers]
    puts "- Sample headers:"
    message[:headers].first(3).each do |header|
      puts "  - #{header[:name]}: #{header[:value]}"
    end
  end
  puts "Request ID: #{request_id}"
  
  message
end

def demonstrate_message_fields_constants
  puts "\n=== Message Fields Constants ==="
  puts "Available MessageFields constants:"
  puts "- STANDARD: #{Nylas::MessageFields::STANDARD}"
  puts "- INCLUDE_HEADERS: #{Nylas::MessageFields::INCLUDE_HEADERS}"
  puts "- INCLUDE_TRACKING_OPTIONS: #{Nylas::MessageFields::INCLUDE_TRACKING_OPTIONS}"
  puts "- RAW_MIME: #{Nylas::MessageFields::RAW_MIME}"
end

def main
  # Load .env file if it exists
  load_env_file
  
  # Check for required environment variables
  api_key = ENV["NYLAS_API_KEY"]
  grant_id = ENV["NYLAS_GRANT_ID"]
  
  raise "NYLAS_API_KEY environment variable is not set" unless api_key
  raise "NYLAS_GRANT_ID environment variable is not set" unless grant_id
  
  puts "Using API key: #{api_key[0..4]}..."
  puts "Using grant ID: #{grant_id[0..8]}..."
  
  # Initialize the Nylas client
  nylas = Nylas::Client.new(
    api_key: api_key,
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )
  
  puts "\n=== Nylas Message Fields Example ==="
  
  begin
    # Demonstrate the constants
    demonstrate_message_fields_constants
    
    # Example 1: List messages with standard fields (default)
    standard_messages = list_messages_with_standard_fields(nylas, grant_id)
    
    # Example 2: List messages with tracking options
    tracking_messages = list_messages_with_tracking_options(nylas, grant_id)
    
    # Example 3: Get a specific message with raw MIME data
    if standard_messages.any?
      message_id = standard_messages.first[:id]
      get_message_with_raw_mime(nylas, grant_id, message_id)
      
      # Example 4: Get a message with headers
      get_message_with_headers(nylas, grant_id, message_id)
    else
      puts "\nNo messages available to demonstrate raw MIME and headers retrieval"
    end
    
    puts "\n=== Example completed successfully! ==="
    
  rescue Nylas::NylasApiError => e
    puts "\nAPI Error: #{e.message}"
    puts "Type: #{e.type}"
    puts "Status Code: #{e.status_code}"
    puts "Request ID: #{e.request_id}" if e.request_id
  rescue StandardError => e
    puts "\nError: #{e.message}"
    puts e.backtrace.first(5)
  end
end

main if __FILE__ == $PROGRAM_NAME 