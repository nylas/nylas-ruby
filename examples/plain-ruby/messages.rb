require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Messages API. See https://docs.nylas.com/reference#messages for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Retrieving a count of messages
demonstrate { api.messages.count }

# Retrieving a message
demonstrate { api.messages.first.to_h }

# Retrieving an expanded message
demonstrate { api.messages.expanded.first.to_h }

message = api.messages.first
# Starring and marking a message as unread
demonstrate { message.update(starred: true, unread: true) }
reloaded_message = api.messages.first
demonstrate { { starred: reloaded_message.starred, unread: reloaded_message.unread } }

# Messages cannot be created
demonstrate do
  begin
    api.messages.create
  rescue Nylas::MethodNotAllowed => e
    "#{e.class}: #{e.message}"
  end
end

# Messages cannot be destroyed
message = api.messages.first
demonstrate do
  begin
    message.destroy
  rescue Nylas::MethodNotAllowed => e
    "#{e.class}: #{e.message}"
  end
end

