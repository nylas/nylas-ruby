require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Drafts API. See https://docs.nylas.com/reference#drafts for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Getting all job statuses
demonstrate { api.job_statuses }

# Get a specific job status
demonstrate do
  job_status = api.job_statuses.first
  api.job_statuses.find(job_status.job_status_id).to_h
end

# Get a boolean value representing status
demonstrate { api.job_statuses.first.successful? }