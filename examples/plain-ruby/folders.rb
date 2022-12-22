require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(client_id: ENV['NYLAS_APP_ID'], client_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_FOLDER_USERS_ACCESS_TOKEN'])

# Retrieving the count of folders
demonstrate { api.folders.count }

# Retrieving a list of folders
demonstrate { api.folders.map(&:to_h) }
folder = api.folders.last

# Retrieving a folder by ID
demonstrate { api.folders.find(folder.id).to_h }

# Creating a folder
demonstrate { api.folders.create(display_name: "Example folder").to_h }

example_folders = api.folders.select do |folder|
  folder.display_name == "Example folder"
end

# Changing a folder
folder_to_change = example_folders.first
demonstrate { folder_to_change.update(display_name: "Changed name") }
demonstrate { api.folders.find(folder_to_change.id).to_h }


# Destroying the folder
demonstrate { folder_to_change.destroy }
