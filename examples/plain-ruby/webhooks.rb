require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Webhooks API. See https://docs.nylas.com/reference#webhooks for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'])


# Webhooks can be retrieved as a collection
demonstrate { api.webhooks.map(&:to_h) }
# Or independently
example_webhook = api.webhooks.first
demonstrate { api.webhooks.find(example_webhook.id).to_h }


