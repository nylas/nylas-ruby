require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

message_id = api.messages.first.id

# Perform sentiment analysis on a string
sentiment = api.neural.sentiment_analysis_text("Hello world")
demonstrate { sentiment.to_h }

# Perform sentiment analysis on a message
sentiments = api.neural.sentiment_analysis_message([message_id])
demonstrate { sentiments[0].to_h }

# Perform extracting a signature and parsing its contact information
signatures = api.neural.extract_signature([message_id])
demonstrate { signatures[0].to_h }
demonstrate { signatures[0].to_h }
# Convert the parsed contact to a Nylas contact object
contact = signatures[0].contacts.to_contact_object
demonstrate { contact.to_h }

# Perform OCR request on a page (with a page range)
begin
  file_id = api.files.first.id
  ocr = api.neural.ocr_request(file_id, [2,3])
  demonstrate { ocr.to_h }
rescue Nylas::Error
  puts "No file found or file found was not compatible with the OCR endpoint"
end

# Perform category analysis on a message
categorize_list = api.neural.categorize([message_id])
demonstrate { categorize_list[0].to_h }
# Re-categorize the message to a different category
categorize = categorize_list[0].recategorize("conversation")
demonstrate { categorize.to_h }

# Clean the conversation of a message
conversations = api.neural.clean_conversation([message_id])
demonstrate { conversations[0].to_h }
# Provide some options to the endpoint
options = Nylas::NeuralMessageOptions.new(ignore_images: false)
conversations = api.neural.clean_conversation([message_id], options)
demonstrate { conversations[0].to_h }
# Parse the images from the clean conversation
extracted_images = conversations[0].extract_images
demonstrate { extracted_images }
