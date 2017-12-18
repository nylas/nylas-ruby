require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])


# How many threads are there?
demonstrate { api.threads.count }

# Threads cannot be created
demonstrate do
  begin
    api.threads.create
  rescue Nylas::MethodNotAllowed => e
    "#{e.class}: #{e.message}"
  end
end


thread = api.threads.first
# Threads have quite a bit of information
demonstrate { thread.to_h }

# Threads may have their unread/starred statuses updated
demonstrate { thread.update(starred: true, unread: true) }
reloaded_thread = api.threads.first
demonstrate { { starred: reloaded_thread.starred, unread: reloaded_thread.unread } }

# Threads may not be destroyed

demonstrate do
  begin
    thread.destroy
  rescue Nylas::EndpointNotYetImplemented => e
    "#{e.class}: #{e.message}"
  end
end

