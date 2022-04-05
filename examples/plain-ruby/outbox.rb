require_relative '../helpers'
require 'date'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Prepare the draft and timestamps
draft = Nylas::Draft.new(to: [{ email: ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-a-real-email@example.com'), name: "Me" }],
                          subject: "A new draft!",
                          metadata: {sdk: "Ruby SDK"})
tomorrow = Date.today + 1
day_after = tomorrow + 1

# Send the message to the outbox
outbox_job_status = demonstrate { api.outbox.send(draft, send_at: tomorrow.to_time.to_i, retry_limit_datetime: day_after.to_time.to_i) }

# Update the outbox message using the OutboxMessage object returned by the OutboxJobStatus object
demonstrate do
  outbox_message = outbox_job_status.original_data
  outbox_message.subject = "Updated Subject"
  api.outbox.update(outbox_job_status.job_status_id, outbox_message)
end

# Or, you can update the draft directly and use that object
demonstrate do
  draft.subject = "Another Updated Subject"
  api.outbox.update(outbox_job_status.job_status_id, draft)
end

# Delete the outbox draft status
demonstrate { api.outbox.delete(outbox_job_status.job_status_id) }
