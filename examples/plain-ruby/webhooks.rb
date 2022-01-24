require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Webhooks API. See https://docs.nylas.com/reference#webhooks for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'])


# Webhooks can be retrieved as a collection
demonstrate { api.webhooks.map(&:to_h) }

# Or independently
example_webhook = api.webhooks.first
demonstrate { api.webhooks.find(example_webhook.id).to_h }

# Create a webhook
demonstrate do
  api.webhooks.create(
    callback_url: ENV['NYLAS_WEBHOOK_URL'],
    state: "active",
    triggers: ["event.created"],
  )
end

# Update the status of the webhook
created_webhook = api.webhooks.last
demonstrate { created_webhook.update(state: "inactive") }

# Delete webhook
demonstrate { created_webhook.destroy }
