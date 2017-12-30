require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to listen for streamed Deltas
# See https://docs.nylas.com/reference#streaming-delta-updates
require 'nylas-streaming'

puts "Once this starts, it will listen forever, hit ctrl+c to move forward in the examples listening!"
def interactive_stream(include_types: [], exclude_types: [])
  EventMachine.run do
    puts "Hit enter to listen for events with include_types #{include_types} and exclude_types " \
           "#{exclude_types}"
    gets
    Signal.trap("INT") do
      puts "Done listening for events with include_types #{include_types} and exclude_types #{exclude_types}!"
      EventMachine.stop
    end
    Signal.trap("TERM") { EventMachine.stop }

    api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                         access_token: ENV['NYLAS_ACCESS_TOKEN'])
    Nylas::Streaming.deltas(api: api, cursor: ENV['NYLAS_PREVIOUS_CURSOR'],
                            include_types: include_types, exclude_types: exclude_types) do |delta|
      puts "#{delta.event} of #{delta.object} #{delta.model.id} as a #{delta.class}"
    end

  end
end

interactive_stream

interactive_stream(include_types:['message'])
interactive_stream(exclude_types:['message'])
