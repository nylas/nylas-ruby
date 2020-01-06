require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Calendar API.
# See https://docs.nylas.com/reference#calendars
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])


# Retrieving the ids of all the calendars
demonstrate { api.calendars.ids }

# Retrieving the count of the calendars
demonstrate { api.calendars.count }

# Listing calendars
demonstrate { api.calendars.limit(2).map(&:to_h) }

# Retrieving a single calendar by ID
demonstrate { api.calendars.find(example_calendar.id).to_h }
