require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Events API.
# See https://docs.nylas.com/reference#events
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Counting the events
demonstrate { api.events.count }

# Retrieving a few events
demonstrate { api.events.limit(2).map(&:to_h) }

# Expand recurring events into independent event objects
demonstrate { api.events.expand_recurring.map(&:to_h) }

# Include cancelled events
demonstrate { api.events.show_cancelled.map(&:to_h) }

# Retrieving a particular event
example_event = api.events.last
demonstrate { api.events.find(example_event.id).to_h }

calendar = api.calendars.reject(&:read_only?).first
# Creating an event
demonstrate { api.events.create(title: "A fun event!", location: "The Party Zone", calendar_id: calendar.id,
                                when: { start_time: Time.now + 60, end_time: Time.now + 120 }).to_h }

example_event = api.events.where(location: "The Party Zone").last

# Updating an event
demonstrate do  example_event.update(
  location: "Somewhere else!",
  metadata: {
    event_type: "gathering"
  }
)
end
demonstrate { api.events.find(example_event.id).location }
demonstrate { api.events.where(metadata_pair:{"event_type": "gathering"}).last.metadata[:event_type] }

# TODO::Uncomment below when job status support is implemented
#   as we can't delete an event with conferencing/notifications
#   until the job status is complete.
#
# Adding conferencing and notifications
# demonstrate do  example_event.update(
#   conferencing:{
#     provider: "Zoom Meeting",
#     autocreate:{}
#   },
#   notifications: [{
#     type: "email",
#     minutes_before_event: 600,
#     subject: "Test Event Notification",
#     body: "Reminding you about our meeting."
#   }]
# )
# end
#
# TODO::Add some sort of loop until

# Deleting an event
demonstrate { example_event.destroy }

# RSVPing to an Event
calendar = api.calendars.select { |c| c.name == "Emailed events" }.first
event = calendar.events.first
event.rsvp(:yes, notify_participants: true)
event.rsvp(:no, notify_participants: true)
event.rsvp(:maybe, notify_participants: true)

# Generating an ICS File
demonstrate { event.generate_ics }

demonstrate { event.generate_ics(
  ical_uid: "test_uuid",
  method: "add",
  prodid: "test_prodid"
) }
