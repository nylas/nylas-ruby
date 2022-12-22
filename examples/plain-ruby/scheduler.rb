require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Scheduler API.
# See https://developer.nylas.com/docs/api/scheduler/#overview
nylas = Nylas::API.new(client_id: ENV['NYLAS_APP_ID'], client_secret: ENV['NYLAS_APP_SECRET'],
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

# Get Google Availability
begin
  demonstrate { nylas.scheduler.get_google_availability }
rescue Nylas::Error => e
  puts "#{e.class}: #{e.message}"
end

# Get Office 365 Availability
begin
  demonstrate { nylas.scheduler.get_office_365_availability }
rescue Nylas::Error => e
  puts "#{e.class}: #{e.message}"
end

# Get a Scheduler page by Slug
demonstrate { nylas.scheduler.get_page_slug(example_scheduler.slug) }

# Get all available time slots
available_timeslots = nylas.scheduler.get_available_time_slots(example_scheduler.slug)
demonstrate { available_timeslots.inspect }

# Book a timeslot
booking_request = Nylas::SchedulerBookingRequest.new(
  additional_values: {
    important: "true"
  },
  email: "recipient@example.com",
  locale: "en_US",
  name: "John Doe",
  timezone: "America/New_York",
  slot: available_timeslots[0]
)
booking_confirmation = nylas.scheduler.book_time_slot(example_scheduler.slug, booking_request)
demonstrate { booking_confirmation.inspect }

# Cancel a booking
demonstrate { nylas.scheduler.cancel_booking(example_scheduler.slug, booking_confirmation.edit_hash, "Was just a test.") }

# Confirm a booking (Expect an error because we already cancelled this meeting)
begin
  demonstrate { nylas.scheduler.confirm_booking(example_scheduler.slug, booking_confirmation.edit_hash) }
rescue Nylas::Error => e
  puts "#{e.class}: #{e.message}"
end

# Delete a scheduler page
demonstrate { example_scheduler.destroy }
