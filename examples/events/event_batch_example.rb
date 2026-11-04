#!/usr/bin/env ruby
# frozen_string_literal: true

# Run from the repository root:
#   bundle exec ruby examples/events/event_batch_example.rb
#
# Required environment variables:
#   NYLAS_API_KEY, NYLAS_GRANT_ID, NYLAS_CALENDAR_ID,
#   NYLAS_UPDATE_EVENT_ID, NYLAS_DELETE_EVENT_ID
# Optional: NYLAS_API_URI (https://api.us.nylas.com or https://api.eu.nylas.com).
#
# Use a Google or Microsoft test calendar. This example creates one event,
# renames NYLAS_UPDATE_EVENT_ID, and deletes NYLAS_DELETE_EVENT_ID.
# The two existing event IDs must be different and belong to that calendar.
# Eligible failed operations are retried once after the provider's delay.

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "nylas"

def main
  required_env_vars = %w[
    NYLAS_API_KEY NYLAS_GRANT_ID NYLAS_CALENDAR_ID NYLAS_UPDATE_EVENT_ID NYLAS_DELETE_EVENT_ID
  ]
  if required_env_vars.any? { |name| ENV[name].nil? || ENV[name].strip.empty? }
    warn "Set the required environment variables listed at the top of this example."
    return 1
  end

  api_uri = ENV.fetch("NYLAS_API_URI", "https://api.us.nylas.com")
  unless %w[https://api.us.nylas.com https://api.eu.nylas.com].include?(api_uri)
    warn "Use a supported Nylas API URL."
    return 1
  end

  nylas = Nylas::Client.new(api_key: ENV["NYLAS_API_KEY"], api_uri: api_uri)
  grant_id = ENV["NYLAS_GRANT_ID"]
  # Query parameters apply to every operation. Omit notify_participants to use
  # the server default of true; Microsoft rejects false. Optional parameters also
  # include grant_email, tentative_as_busy, and select (a comma-separated field list).
  query_params = { calendar_id: ENV["NYLAS_CALENDAR_ID"] }
  start_time = Time.now.to_i + (24 * 60 * 60)
  operations = [
    {
      method: "create",
      body: { title: "Standup", when: { start_time: start_time, end_time: start_time + 1800 } }
    },
    { method: "update", event_id: ENV["NYLAS_UPDATE_EVENT_ID"], body: { title: "Renamed" } },
    { method: "delete", event_id: ENV["NYLAS_DELETE_EVENT_ID"] }
  ]

  # Bodies use the same event hashes as events.create and events.update.
  # The tuple is [results, request_id, headers], without a pagination cursor.
  results, _request_id, _headers = nylas.events.batch(
    identifier: grant_id,
    query_params: query_params,
    request_body: { operations: operations }
  )

  # HTTP 207 returns normally, even if every operation failed. Results preserve
  # operation order and use symbol keys. Check every result's status and error.
  results.each_with_index do |item, index|
    puts "Operation #{index}: #{item[:status]}"
    # Successful creates/updates have an event in item[:data]; deletes have no data.
    # Failed items have an error hash with type, message, and optional provider_error.
    next unless item[:error]

    # Never retry these operations: the provider already created the event.
    next if item[:provider_event_created]
    next unless [429, 503].include?(item[:status])

    delay = item[:retry_after]
    next unless delay.is_a?(Numeric) && delay.finite? && delay >= 0

    # Retry this eligible operation once. Zero is a valid delay. The SDK leaves
    # retry decisions to the application and does not retry failed batch items.
    sleep(delay)
    retry_results, _retry_request_id = nylas.events.batch(
      identifier: grant_id,
      query_params: query_params,
      request_body: { operations: [operations[index]] }
    )
    puts "Retry status for operation #{index}: #{retry_results.first[:status]}"
  end

  0
rescue StandardError
  # Invalid whole requests raise Nylas::NylasApiError. Keep credentials and API
  # response details out of example output, including unexpected failure output.
  warn "Unable to complete the batch example."
  1
end

exit(main) if __FILE__ == $PROGRAM_NAME
