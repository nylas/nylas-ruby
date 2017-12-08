require_relative 'helpers'

api = Nylas::API.new(api_version: "1", app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'], access_token:
                     ENV['NYLAS_ACCESS_TOKEN'])

# Retrieving a count of contacts
demonstrate { api.contacts.count }

# Retrieving a subset of contacts using limit
demonstrate { api.contacts.limit(5).map(&:to_h) }
#
# Retrieving the first page of contacts
demonstrate { api.contacts.map(&:to_h) }

# Retrieve all pages of contacts
demonstrate { api.contacts.find_each.map(&:to_h) }
