require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas
# Drafts API. See https://docs.nylas.com/reference#drafts for API documentation
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Creating a draft
demonstrate do
  example_draft = api.drafts.create(subject: "A new draft!")
  example_draft.to_h
end

# Retrieving a count of drafts
demonstrate { api.drafts.count }

# Retrieving drafts as a collection draft
demonstrate { api.drafts.limit(2).map(&:to_h) }
example_draft =  api.drafts.first

# Retrieving a particular drafts
demonstrate { api.drafts.find(example_draft.id) }

# Sending a draft
demonstrate do
  draft = api.drafts.create(to: [{ email: ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-a-real-email@example.com')}],
                            subject: "A new draft!")
  draft.send!
end

# Updating a draft
demonstrate do
  example_draft.to << { name: "Other person", email: "other@example.com" }
  example_draft.save
  api.drafts.find(example_draft.id).to.map(&:to_h)
end

# Destroying a draft

demonstrate do
  example_draft.destroy
end
