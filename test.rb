# frozen_string_literal: true

require_relative "lib/nylas"

nylas = Nylas::Client.new(api_key: "key")

begin
  response = nylas.calendars.find({ grant_id: "albert.t@nylas.com", id: ".t@nylas.com" })
rescue StandardError => e
  response = e
end
puts response

begin
  response = nylas.events.list({ grant_id: "albert.t@nylas.com" },
                               query_params: { calendar_id: "albert.t@nylas.com" })
rescue StandardError => e
  response = e
end
puts response
