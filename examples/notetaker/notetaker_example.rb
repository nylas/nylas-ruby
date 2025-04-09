#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require "nylas"
require "json"

# Initialize the Nylas client
nylas = Nylas::Client.new(
  api_key: ENV["NYLAS_API_KEY"],
  api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
)

def invite_notetaker(nylas)
  puts "\n=== Inviting Notetaker to Meeting ==="
  
  meeting_link = ENV["MEETING_LINK"]
  raise "MEETING_LINK environment variable is not set. Please set it with your meeting URL." unless meeting_link
  
  request_body = {
    meeting_link: meeting_link,
    name: "Nylas Notetaker",
    meeting_settings: {
      video_recording: true,
      audio_recording: true,
      transcription: true
    }
  }
  
  puts "Request body: #{JSON.pretty_generate(request_body)}"
  
  notetaker, request_id = nylas.notetakers.create(request_body: request_body)
  
  puts "Invited Notetaker with ID: #{notetaker[:id]}"
  puts "Name: #{notetaker[:name]}"
  puts "State: #{notetaker[:state]}"
  puts "Request ID: #{request_id}"
  notetaker
end

def list_notetakers(nylas)
  puts "\n=== Listing All Notetakers ==="
  notetakers, request_id = nylas.notetakers.list
  
  puts "Found #{notetakers.length} notetakers:"
  notetakers.each do |notetaker|
    puts "- #{notetaker[:name]} (ID: #{notetaker[:id]}, State: #{notetaker[:state]})"
  end
  puts "Request ID: #{request_id}"
  
  notetakers
end

def get_notetaker_media(nylas, notetaker_id)
  puts "\n=== Getting Notetaker Media ==="
  media, request_id = nylas.notetakers.download_media(notetaker_id: notetaker_id)
  
  if media[:recording]
    puts "Recording URL: #{media[:recording][:url]}"
    puts "Recording Size: #{media[:recording][:size]} MB"
  end
  if media[:transcript]
    puts "Transcript URL: #{media[:transcript][:url]}"
    puts "Transcript Size: #{media[:transcript][:size]} MB"
  end
  puts "Request ID: #{request_id}"
  
  media
end

def leave_notetaker(nylas, notetaker_id)
  puts "\n=== Leaving Notetaker ==="
  _, request_id = nylas.notetakers.leave(notetaker_id: notetaker_id)
  puts "Left Notetaker with ID: #{notetaker_id}"
  puts "Request ID: #{request_id}"
end

def main
  # Check for required environment variables
  api_key = ENV["NYLAS_API_KEY"]
  raise "NYLAS_API_KEY environment variable is not set" unless api_key
  puts "Using API key: #{api_key[0..4]}..."
  
  # Initialize Nylas client
  nylas = Nylas::Client.new(
    api_key: api_key,
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )
  
  # Invite a Notetaker to a meeting
  notetaker = invite_notetaker(nylas)
  
  # List all Notetakers
  list_notetakers(nylas)
  
  # Get media from the Notetaker (if available)
  if notetaker[:state] == "media_available"
    get_notetaker_media(nylas, notetaker[:id])
  end
  
  # Leave the Notetaker
  leave_notetaker(nylas, notetaker[:id])
end

main if __FILE__ == $PROGRAM_NAME 