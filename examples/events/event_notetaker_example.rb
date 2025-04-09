#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require "nylas"
require "json"
require "time"

# Initialize the Nylas client
nylas = Nylas::Client.new(
  api_key: ENV["NYLAS_API_KEY"],
  api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
)

def create_event_with_notetaker(nylas)
  puts "\n=== Creating Event with Notetaker ==="
  
  # Create the event time
  start_time = Time.now + (24 * 60 * 60) # tomorrow
  end_time = start_time + (60 * 60) # 1 hour later
  
  request_body = {
    title: "Project Planning Meeting",
    description: "Initial project planning and resource allocation",
    when: {
      start_time: start_time.to_i,
      end_time: end_time.to_i
    },
    metadata: {
      project_id: "PROJ-123",
      priority: "high"
    },
    conferencing: {
      provider: "Google Meet",
      autocreate: {}
    },
    notetaker: {
      name: "Nylas Notetaker",
      meeting_settings: {
        video_recording: true,
        audio_recording: true,
        transcription: true
      }
    }
  }
  
  query_params = {
    calendar_id: ENV["NYLAS_CALENDAR_ID"]
  }
  
  puts "Creating event with request body: #{JSON.pretty_generate(request_body)}"
  
  event, request_id = nylas.events.create(
    identifier: ENV["NYLAS_GRANT_ID"],
    request_body: request_body,
    query_params: query_params
  )
  
  puts "Created event with ID: #{event[:id]}"
  puts "Event Notetaker ID: #{event[:notetaker][:id]}"
  puts "Request ID: #{request_id}"
  
  event
end

def get_event_notetaker(nylas, event_id)
  puts "\n=== Retrieving Event Notetaker ==="
  
  # First get the event to get the Notetaker ID
  begin
    event, request_id = nylas.events.find(
      identifier: ENV["NYLAS_GRANT_ID"],
      event_id: event_id,
      query_params: { calendar_id: ENV["NYLAS_CALENDAR_ID"] }
    )
  rescue StandardError => e
    puts "Error getting event: #{e.message}"
    return nil
  end
  
  unless event[:notetaker] && event[:notetaker][:id]
    puts "No Notetaker found for event #{event_id}"
    return nil
  end
  
  notetaker, request_id = nylas.notetakers.find(
    notetaker_id: event[:notetaker][:id],
    identifier: ENV["NYLAS_GRANT_ID"]
  )
  
  puts "Found Notetaker for event #{event_id}:"
  puts "- ID: #{notetaker[:id]}"
  puts "- State: #{notetaker[:state]}"
  puts "- Meeting Provider: #{notetaker[:meeting_provider]}"
  puts "- Meeting Settings:"
  puts "  - Video Recording: #{notetaker[:meeting_settings][:video_recording]}"
  puts "  - Audio Recording: #{notetaker[:meeting_settings][:audio_recording]}"
  puts "  - Transcription: #{notetaker[:meeting_settings][:transcription]}"
  puts "Request ID: #{request_id}"
  
  notetaker
end

def update_event_and_notetaker(nylas, event_id, notetaker_id)
  puts "\n=== Updating Event and Notetaker ==="
  
  request_body = {
    title: "Updated Project Planning Meeting",
    description: "Revised project planning with new timeline",
    metadata: {
      project_id: "PROJ-123",
      priority: "urgent"
    },
    notetaker: {
      id: notetaker_id,
      name: "Updated Nylas Notetaker",
      meeting_settings: {
        video_recording: false,
        audio_recording: true,
        transcription: false
      }
    }
  }
  
  query_params = {
    calendar_id: ENV["NYLAS_CALENDAR_ID"]
  }
  
  updated_event, request_id = nylas.events.update(
    identifier: ENV["NYLAS_GRANT_ID"],
    event_id: event_id,
    request_body: request_body,
    query_params: query_params
  )
  
  puts "Updated event with ID: #{updated_event[:id]}"
  puts "Request ID: #{request_id}"
  
  updated_event
end

def main
  # Check for required environment variables
  required_env_vars = %w[NYLAS_API_KEY NYLAS_GRANT_ID NYLAS_CALENDAR_ID]
  missing_vars = required_env_vars.select { |var| ENV[var].nil? }
  
  unless missing_vars.empty?
    raise "Missing required environment variables: #{missing_vars.join(', ')}"
  end
  
  puts "Using API key: #{ENV['NYLAS_API_KEY'][0..4]}..."
  
  # Initialize Nylas client
  nylas = Nylas::Client.new(
    api_key: ENV["NYLAS_API_KEY"],
    api_uri: ENV["NYLAS_API_URI"] || "https://api.us.nylas.com"
  )
  
  begin
    # Create an event with a Notetaker
    event = create_event_with_notetaker(nylas)
    unless event
      puts "Failed to create event"
      return
    end
    
    # Get the Notetaker for the event
    notetaker = get_event_notetaker(nylas, event[:id])
    unless notetaker
      puts "Failed to get Notetaker for event #{event[:id]}"
      return
    end
    
    # Update both the event and its Notetaker
    updated_event = update_event_and_notetaker(nylas, event[:id], notetaker[:id])
    unless updated_event
      puts "Failed to update event #{event[:id]}"
      return
    end
    
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end

main if __FILE__ == $PROGRAM_NAME 