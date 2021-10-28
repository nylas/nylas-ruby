require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Scheduler API.
# See https://developer.nylas.com/docs/api/scheduler/#overview
nylas = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Create a scheduler page
demonstrate { nylas.scheduler.create(access_tokens: [ENV['NYLAS_ACCESS_TOKEN']], name: "Ruby SDK Example", slug: "ruby_example_#{Time.now.to_i}") }

# List all scheduler pages
demonstrate { nylas.scheduler }

# Return a specific scheduler page
example_scheduler = nylas.scheduler.last
demonstrate { nylas.scheduler.find(example_scheduler.id).to_h }

# Modify a specific scheduler page
demonstrate do example_scheduler.update(
  name: "Updated name"
)
end
demonstrate { example_scheduler.name }

# Get available calendars
demonstrate { example_scheduler.get_available_calendars }

# Upload an image
demonstrate { example_scheduler.upload_image(content_type: "image/png", object_name: "test.png") }

# Delete a scheduler page
demonstrate { example_scheduler.destroy }
