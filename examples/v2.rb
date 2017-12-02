require_relative 'helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API
# It follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).

# ### V2
# To create a connection to the Nylas SDK using V2 of the API:
api = Nylas::API.new(api_version: "2", app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# The HTTP request to be made when retrieving all contacts
demonstrate { api.contacts.to_be_executed }

# Retrieving a count of contacts
demonstrate { api.contacts.count }

search_results = api.contacts.limit(5)

# The HTTP request to be made when retrieving all contacts
demonstrate { search_results.to_be_executed }

search_results.each do |result|
  demonstrate { result.to_h }
end

# Instantiating a new contact
contact = api.contacts.new(given_name: "Rando")
contact.save

demonstrate { api.contacts.count }

contact.destroy

demonstrate { api.contacts.count }
