require_relative '../helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to send messages via the API
# See https://docs.nylas.com/reference#sending
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Sending a message as a hash
demonstrate do
  api.send!(to: [{ email: ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-a-real-email@example.com'),
                          name: "An example recipient" }],
                   subject: "you've got mail!",
                   body: "It's a really good mail!").to_h
end

# Sending a message by instantiating a message instance
demonstrate do
  message = Nylas::NewMessage.new(to: [{ email: ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-a-real-email@example.com'),
                                         name: "An example recipient" }],
                                  subject: "you've got another mail!",
                                  body: "It's a really good another mail!", api: api)
  message.send!.to_h
end

# Sending a message as a mime string
#
demonstrate do
  message_string = "MIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\n" \
                   "Subject: A mime email\n" \
                   "From: You <your-email@example.com>\n" \
                   "To: You <#{ENV.fetch('NYLAS_EXAMPLE_EMAIL', 'not-real@example.com')}>\n\n" \
                   "This is the body of the message sent as a raw mime!"
  api.send!(message_string)
end
