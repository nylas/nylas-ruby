require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Messages API. See https://docs.nylas.com/reference#messages for API documentation
api = Nylas::API.new(client_id: ENV['NYLAS_APP_ID'], client_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Retrieving a count of messages
demonstrate { api.messages.count }

# Retrieving a message
demonstrate { api.messages.first.to_h }

# Retrieving an expanded message
demonstrate { api.messages.expanded.first.to_h }

message = api.messages.first
# Retrieving a raw message
demonstrate { api.messages.raw.find(message.id) }

# Starring and marking a message as unread
demonstrate { message.update(starred: true, unread: true) }
reloaded_message = api.messages.first
demonstrate { { starred: reloaded_message.starred, unread: reloaded_message.unread } }

# Messages cannot be created
demonstrate do
  begin
    api.messages.create
  rescue Nylas::ModelNotCreatableError => e
    "#{e.class}: #{e.message}"
  end
end

# Messages cannot be destroyed
message = api.messages.first
demonstrate do
  begin
    message.destroy
  rescue Nylas::ModelNotDestroyableError => e
    "#{e.class}: #{e.message}"
  end
end

# Messages may be searched.
# See https://docs.nylas.com/reference#messages-search and https://docs.nylas.com/reference#search
demonstrate { api.messages.search("That really important email").map(&:to_h) }

