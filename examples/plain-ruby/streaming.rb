require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to listen for streamed Deltas
# See https://docs.nylas.com/reference#streaming-delta-updates
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])
require 'nylas-streaming'

puts "Once this starts, it will listen forever, hit ctrl+c to move forward in the examples listening!"

puts "Hit enter to listen for every delta after #{ENV["NYLAS_PREVIOUS_CURSOR"]}"
gets.chomp

EventMachine.run do
  Signal.trap("INT")  { puts "Done listening for everything!", EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }
  Nylas::Streaming.deltas(api: api, cursor: ENV['NYLAS_PREVIOUS_CURSOR']) do |delta|
    puts "#{delta.event} of #{delta.object} #{delta.model.id} as a #{delta.class}"
  end
end


puts "Hit enter to listen for only message deltas after #{ENV["NYLAS_PREVIOUS_CURSOR"]}"
gets.chomp
EventMachine.run do
  Signal.trap("INT")  { EventMachine.stop; puts "Done listening for messages!" }
  Signal.trap("TERM") { EventMachine.stop }
  Nylas::Streaming.deltas(api: api, cursor: ENV['NYLAS_PREVIOUS_CURSOR'],
                          include_types:['message']) do |delta|
    puts("Received #{delta.event} of #{delta.object} #{delta.model.id} as a #{delta.class}")
  end
end

puts "Hit enter to listen for everything but message deltas after #{ENV["NYLAS_PREVIOUS_CURSOR"]}"
gets.chomp
EventMachine.run do
  Signal.trap("INT")  { EventMachine.stop; puts "Done listening for non messages!" }
  Signal.trap("TERM") { EventMachine.stop }
  Nylas::Streaming.deltas(api: api, cursor: ENV['NYLAS_PREVIOUS_CURSOR'],
                          exclude_types:['message']) do |delta|
    puts("Received #{delta.event} of #{delta.object} #{delta.model.id} as a #{delta.class}")
  end
end
