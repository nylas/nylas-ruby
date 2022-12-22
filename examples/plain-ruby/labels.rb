require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(client_id: ENV['NYLAS_APP_ID'], client_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Retrieving the count of labels
demonstrate { api.labels.count }

# Retrieving a list of labels
demonstrate { api.labels.map(&:to_h) }
label = api.labels.last

# Retrieving a label by ID
demonstrate { api.labels.find(label.id).to_h }

# Creating a label
demonstrate { api.labels.create(display_name: "Example label").to_h }

example_labels = api.labels.select do |label|
  label.display_name == "Example label"
end

# Changing a label
label_to_change = example_labels.first
demonstrate { label_to_change.update(display_name: "Changed name") }
demonstrate { api.labels.find(label_to_change.id).to_h }


# Destroying the label
demonstrate { label_to_change.destroy }
