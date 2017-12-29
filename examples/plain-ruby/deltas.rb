require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas #
# Deltas API.
# See https://docs.nylas.com/reference#deltas
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Retrieves the latest cursor
demonstrate { api.deltas.latest_cursor }

# Retrieves the latest colletion of deltas
latest_deltas = demonstrate { api.deltas.latest.class }

# Retrieves a particular cursor
deltas_from_cursor = demonstrate { api.deltas.since(ENV['NYLAS_PREVIOUS_CURSOR']) }

# Get the raw deltas data
demonstrate { deltas_from_cursor.to_h }

# Get the model from the object data
demonstrate { deltas_from_cursor.first&.model&.class }
