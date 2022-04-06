require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'])

# Create a component
# NOTE: you will need to set the account_id and the access_token
demonstrate { api.components.create(name: "Ruby Component Test", type: "agenda", public_account_id: ENV['NYLAS_ACCOUNT_ID'], access_token: ENV['NYLAS_ACCESS_TOKEN']) }

# Get all components
demonstrate { api.components }

# Retrieving a particular component
example_component = api.components.last
demonstrate { api.components.find(example_component.id).to_h }

# Editing a particular component
demonstrate do  example_component.update(
  name: "New Updated Ruby Name"
)
end
demonstrate { example_component.name }

# Delete a component
demonstrate { example_component.destroy }