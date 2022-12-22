require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas #
# Deltas API.
# See https://docs.nylas.com/reference#deltas
api = Nylas::API.new(client_id: ENV['NYLAS_APP_ID'], client_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])


# Retrieves the latest colletion of deltas
latest_deltas = demonstrate { api.deltas.latest.class }

# Retrieves a particular cursor
deltas_from_cursor = demonstrate { api.deltas.since(ENV['NYLAS_PREVIOUS_CURSOR']) }

# Get the deltas metadata
demonstrate { deltas_from_cursor.cursor_end }
demonstrate { deltas_from_cursor.cursor_start }
demonstrate { deltas_from_cursor.count }
# Retrieves the latest cursor
demonstrate { api.deltas.latest_cursor }


# Retrieving multiple pages of deltas
demonstrate { deltas_from_cursor.find_each.map(&:id).count }

# 5 delta's
demonstrate { deltas_from_cursor.take(5).map(&:to_h) }

# Models are cast to Nylas::Model objects
demonstrate { deltas_from_cursor.first&.model&.class }

# And can be viewed directly
demonstrate { deltas_from_cursor.first&.to_h }
