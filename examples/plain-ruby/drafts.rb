require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Drafts API. See https://docs.nylas.com/reference#drafts for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])


# Retrieving a count of drafts
# demonstrate { api.drafts.count }

# Retrieving a draft
puts api.drafts.first.to_h
demonstrate { api.drafts.first.to_h }

