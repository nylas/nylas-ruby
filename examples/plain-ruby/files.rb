require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the Nylas Files
# API.
# See https://docs.nylas.com/reference#files
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Listing files
demonstrate { api.files.limit(2).map(&:to_h) }

# Retrieving file metadata
example_file = api.files.first
demonstrate { api.files.find(example_file.id).to_h }

# Downloading a particular file
demonstrate { example_file.download }

# Downloading a particular file is cached. Notice the path didn't change
demonstrate { example_file.download }

# Re-downloading a file, notice the path does change.
demonstrate { example_file.download! }

# Uploading a file
demonstrate do
  api.files.create(file: File.open(File.expand_path(__FILE__), 'r')).to_h
end
