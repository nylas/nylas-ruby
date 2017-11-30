# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API
# It follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
#

require 'method_source'
def demonstrate(&block)
  block.source.display
  puts "# => #{block.call}"
end

# ### V2
# To create a connection to the Nylas SDK using V2 of the API:
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'nylas'
api = Nylas::API.new(api_version: "2", app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

search_results = api.contacts.where(email: 'person@example.com', phone_number: '123456890', postal_code: '12345', state: 'ca',
                                    country: "USA")

demonstrate { search_results.count == 0 }
demonstrate do
  search_results.each do |result|
  end
end

