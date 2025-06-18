#!/usr/bin/env ruby
# frozen_string_literal: true

# Example demonstrating the single_level query parameter in the Nylas Ruby SDK Folders API
#
# This example shows how to:
# 1. List folders with default multi-level hierarchy
# 2. List folders with single-level hierarchy (Microsoft accounts only)
# 3. Combine single_level with other query parameters
#
# Prerequisites:
# - Ruby 3.0 or later
# - A Nylas API key
# - A grant ID (connected email account, preferably Microsoft for full functionality)
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

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "nylas"
require "json"

# Simple .env file loader
def load_env_file
  env_file = File.expand_path("../.env", __dir__)
  return unless File.exist?(env_file)

  puts "Loading environment variables from .env file..."
  File.readlines(env_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    next unless key && value

    # Remove quotes if present
    value = value.gsub(/\A['"]|['"]\z/, "")
    ENV[key] = value
  end
end

def list_folders_multi_level(nylas, grant_id)
  puts "\n=== Listing Folders with Multi-Level Hierarchy (Default) ==="

  folders, request_id, next_cursor = nylas.folders.list(
    identifier: grant_id
  )

  puts "Found #{folders.length} folders in multi-level hierarchy"
  display_folders(folders)
  puts "Request ID: #{request_id}"
  puts "Next cursor: #{next_cursor || 'None'}"

  folders
end

def list_folders_single_level(nylas, grant_id)
  puts "\n=== Listing Folders with Single-Level Hierarchy (Microsoft Only) ==="

  folders, request_id, next_cursor = nylas.folders.list(
    identifier: grant_id,
    query_params: { single_level: true }
  )

  puts "Found #{folders.length} folders in single-level hierarchy"
  display_folders(folders)
  puts "Request ID: #{request_id}"
  puts "Next cursor: #{next_cursor || 'None'}"

  folders
end

def list_folders_with_additional_params(nylas, grant_id)
  puts "\n=== Listing Folders with Single-Level + Additional Parameters ==="

  folders, request_id, next_cursor = nylas.folders.list(
    identifier: grant_id,
    query_params: {
      single_level: true,
      limit: 5
    }
  )

  puts "Found #{folders.length} folders (limited to 5) in single-level hierarchy"
  display_folders(folders)
  puts "Request ID: #{request_id}"
  puts "Next cursor: #{next_cursor || 'None'}"

  folders
end

def display_folders(folders)
  if folders.empty?
    puts "  No folders found"
    return
  end

  folders.each do |folder|
    parent_info = folder[:parent_id] ? "Parent: #{folder[:parent_id]}" : "Root folder"
    system_folder = folder[:system_folder] ? " (System)" : ""
    puts "  - #{folder[:name]}#{system_folder}"
    puts "    ID: #{folder[:id]}"
    puts "    #{parent_info}"
    puts "    Unread: #{folder[:unread_count] || 0}, Total: #{folder[:total_count] || 0}"
    puts
  end
end

def demonstrate_single_level_parameter
  puts "\n=== Single-Level Parameter Documentation ==="
  puts "The single_level parameter is designed for Microsoft accounts and controls folder hierarchy:"
  puts "- single_level: true  -> Retrieves folders from a single-level hierarchy only"
  puts "- single_level: false -> Retrieves folders across a multi-level hierarchy (default)"
  puts "- This parameter is most effective with Microsoft Exchange/Outlook accounts"
  puts "- Other providers may not show significant differences in behavior"
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

  puts "\n=== Nylas Folders Single-Level Parameter Example ==="

  begin
    # Demonstrate the parameter concept
    demonstrate_single_level_parameter

    # Example 1: List folders with default multi-level hierarchy
    multi_level_folders = list_folders_multi_level(nylas, grant_id)

    # Example 2: List folders with single-level hierarchy
    single_level_folders = list_folders_single_level(nylas, grant_id)

    # Example 3: List folders with single-level and additional parameters
    list_folders_with_additional_params(nylas, grant_id)

    # Compare results if both calls returned folders
    if multi_level_folders.any? && single_level_folders.any?
      puts "\n=== Comparison ==="
      puts "Multi-level hierarchy returned: #{multi_level_folders.length} folders"
      puts "Single-level hierarchy returned: #{single_level_folders.length} folders"

      if multi_level_folders.length != single_level_folders.length
        puts "Different folder counts suggest the single_level parameter is working as expected."
      else
        puts "Same folder count - this might indicate:"
        puts "- The account doesn't have nested folders"
        puts "- The provider doesn't support hierarchical folders"
        puts "- The account is not a Microsoft account"
      end
    end
  rescue StandardError => e
    puts "\nError occurred: #{e.message}"
    puts "This might happen if:"
    puts "- The API key or grant ID is invalid"
    puts "- The account doesn't have permission to access folders"
    puts "- Network connectivity issues"
    puts "\nFull error details:"
    puts e.inspect
  end

  puts "\n=== Example completed ==="
end

# Run the example if this file is executed directly
main if __FILE__ == $PROGRAM_NAME
