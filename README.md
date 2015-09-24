# Nylas REST API Ruby bindings

## Installation

Add this line to your application's Gemfile:

    gem 'nylas'

And then execute:

    bundle

You don't need to use this repo unless you're planning to modify the gem. If you just want to use the Inbox SDK with Ruby bindings, you should run:

    gem install nylas


##Requirements

- Ruby 1.8.7 or above. (Ruby 1.8.6 may work if you load ActiveSupport.)

- rest-client, json, yajl-ruby, em-http-request


## Examples

### Sinatra App

A small example of a Sintra app is included in the `examples/sinatra` directory. You can check-out the `README.md` in the sinatra folder to learn more about the example

```
cd examples/sinatra
ruby index.rb
```

### Rails App

A small example Rails app is included in the `examples/rails` directory. You can run the sample app to see how an authentication flow might be implemented.

```
cd examples/rails
RESTCLIENT_LOG=stdout rails s
```

**Note:** *You will need to replace the Nylas App ID and Secret in `config/environments/development.rb` to use the sample app.*

## Usage

### App ID and Secret

Before you can interact with the Nylas API, you need to register for the Nylas Developer Program at [https://www.nylas.com/](https://www.nylas.com/). After you've created a developer account, you can create a new application to generate an App ID / Secret pair.

Generally, you should store your App ID and Secret into environment variables to avoid adding them to source control. That said, in the example project and code snippets below, the values were added to `config/environments/development.rb` for convenience.


### Authentication

The Nylas REST API uses server-side (three-legged) OAuth, and the Ruby gem provides convenience methods that simplify the OAuth process. For more information about authenticating with Nylas, visit the [Developer Documentation](https://nylas.com/docs/platform#authentication).

**Step 1: Redirect the user to Nylas:**

```ruby
require 'nylas'

def login
  nylas = Nylas::API.new(config.nylas_app_id, config.nylas_app_secret, nil)
  # The email address of the user you want to authenticate
  user_email = 'ben@nylas.com'

  # This URL must be registered with your application in the developer portal
  callback_url = url_for(:action => 'login_callback')

  redirect_to nylas.url_for_authentication(callback_url, user_email)
end
```

**Step 2: Handle the Authentication Response:**

```ruby
def login_callback
  nylas = Nylas::API.new(config.nylas_app_id, config.nylas_app_secret, nil)
  nylas_token = nylas.token_for_code(params[:code])

  # Save the nylas_token to the current session, save it to the user model, etc.
end
```

### Managing Billing

If you're using the open-source version of the Nylas Sync Engine or have fewer than 10 accounts associated with your developer app, you don't need to worry about billing. However, if you've requested production access to the Sync Engine, you are billed monthly based on the number of email accounts you've connected to Nylas.

**Cancelling an Account**

```ruby
  nylas = Nylas::API.new(config.nylas_app_id, config.nylas_app_secret, nil)
  account = nylas.accounts.find(account_id)
  account.downgrade!

  # Your Nylas API token will be revoked, you will not be charged
```

### Account Status

```ruby
  # Query the status of every account linked to the app
  nylas = Nylas::API.new(config.nylas_app_id, config.nylas_app_secret, nylas_token)
  accounts = nylas.accounts
  accounts.each { |a| [a.account_id, a.sync_state] } # Available fields are: account_id, sync_state, trial, trial_expires and billing_state. See lib/account.rb for more details.
```

### Fetching Accounts

```ruby
nylas = Nylas::API.new(config.nylas_app_id, config.nylas_app_secret, nylas_token)

# Print out the email address and provider (Gmail, Exchange)
puts nylas.account.email_address
puts nylas.account.provider
```


### Fetching Threads

```ruby
# Fetch the first thread
thread = nylas.threads.first

# Fetch a specific thread
thread = nylas.threads.find('ac123acd123ef123')

# List all threads tagged `inbox`
# (paginating 50 at a time until no more are returned.)
nylas.threads.where(:tag => 'inbox').each do |thread|
  puts thread.subject
end

# List the 5 most recent unread threads
nylas.threads.where(:tag => 'unread').range(0,4).each do |thread|
  puts thread.subject
end

# List all threads with 'ben@nylas.com'
nylas.threads.where(:any_email => 'ben@nylas.com').each do |thread|
  puts thread.subject
end

# Get number of all threads
count = nylas.threads.count

# Get number of threads with 'ben@inboxapp.com'
count = nylas.threads.where(:any_email => 'ben@inboxapp.com').count

# Collect all threads with 'ben@nylas.com' into an array.
# Note: for large numbers of threads, this is not advised.
threads = nylas.threads.where(:any_email => 'ben@nylas.com').all
```


### Working with Threads

```ruby
# List thread participants
thread.participants.each do |participant|
  puts participant['email']
end

# Mark as read
thread.mark_as_read!

# Archive
thread.archive!

# Add or remove arbitrary tags (DEPRECATED --- you should use the new labels and folders API)
tagsToAdd = ['inbox', 'cfa1233ef123acd12']
tagsToRemove = []
thread.update_tags!(tagsToAdd, tagsToRemove)

# Add a new label to a message

important = nil
nylas.labels.each do |label|
  if label.display_name == 'Important'
    important = label
  end
end

thread = nylas.threads.where(:from => "helena@nylas.com").first
thread.labels.push(important)
thread.save!

# List messages
thread.messages.each do |message|
  puts message.subject
end

# List all messages sent by Ben where Helena was cc'ed:
thread.messages.where(:from => 'ben@nylas.com').each.select { |t|
  t.cc.any? {|p| p['email'] == 'helena@nylas.com' }
}
```


### Working with Files

```ruby
# List files
nylas.files.each do |file|
  puts file.filename
end

# Create a new file
file = nylas.files.build(:file => File.new("./public/favicon.ico", 'rb'))
file.save!

# Download a file's contents
content = file.download
```

### Working with Labels/Folders

The new folders and labels API replaces the now deprecated Tags API. It allows you to apply Gmail labels to whole threads or individual messages and, for providers other than Gmail, to move threads and messages between folders.

```ruby

# List labels
nylas.labels.each do |label|
  puts label.display_name, label.id
end

# Create a label
label = nylas.folders.build(:display_name => 'Test label', :name => 'test name')
label.save!

# Create a folder
#
# Note that Folders and Labels are absolutely identical from the standpoint of the SDK.
# The only difference is that a message can have many labels but only a single folder.
fld = nylas.folders.build(:display_name => 'Test folder', :name => 'test name')
fld.save!

# Rename a folder
#
# Note that you can not rename folders like INBOX, Trash, etc.
fld = nylas.folders.first
fld.display_name = 'Renamed folder'
fld.save!

```

### Working with Messages, Contacts, etc.

#### Filtering

Each of the primary collections (contacts, messages, etc.) behave the same way as `threads`. For example, finding messages with a filter is similar to finding threads:

```ruby
# Let's get all the attachments Ben sent me.
messages = nylas.messages.where(:to => 'ben@nylas.com`)

messages.each do |msg|
    puts msg.subject

    if msg.files? # => returns true if the message has attachments.
        # Download them all.
        msg.files.each |file| do
            puts file.download
        end
    end
end
```

The `where` method accepts a hash of filters, as documented in the [Filters Documentation](https://nylas.com/docs/platform#filters).

#### Enumerator methods

Every object API object has an `each` method which returns an `Enumerator` if you don't pass it a block.
This allows you to do leverage all that Ruby's `Enumerable` has to offer.
For example, this is the previous example rewritten to use an `Enumerator`:

```ruby
messages_with_files = messages.each.select(&:files?)
to_download = messages_with_files.flat_map(&:files)
to_download.map { |file| puts file.download }
```

#### Accessing an object's raw JSON

Sometimes you really need to access the JSON object the API returned. You can use the `#raw_json` property for this:

```ruby
>>> puts contact.raw_json
{
    "name": "Ben Bitdiddle",
    "email": "ben.bitdiddle@mit.edu",
    "id": "8pjz8oj4hkfwgtb46furlh77",
    "account_id": "aqau8ta87ndh6cwv0o3ajfoo2",
    "object": "contact"
}
```

#### Getting a message's Message-Id, References and In-Reply-To headers

If you've building your own threading solution, you'll probably need access to a handful of headers like
`Message-Id`, `In-Reply-To` and `References`. Here's how to access them:

```ruby
msg = nylas.messages.first
expanded_message = msg.expanded
puts expanded_message.message_id
puts expanded_message.references
puts expanded_message.in_reply_to
```

#### Getting the raw contents of a message

It's possible to access the unprocessed contents of a message using the raw method:

```ruby
raw_contents = message.raw
```


### Creating and Sending Drafts

```ruby
# Create a new draft
draft = nylas.drafts.build(
  :to => [{:name => 'Ben Gotow', :email => 'ben@nylas.com'}],
  :subject => "Sent by Ruby",
  :body => "Hi there!<strong>This is HTML</strong>"
)

# Modify attributes as necessary
draft.cc = [{:name => 'Michael', :email => 'mg@nylas.com'}]

# Add the file we uploaded as an attachment
draft.attach(file)

# Save the draft
draft.save!

# Send the draft.
draft.send!

# Sometimes sending isn't possible --- handle the exception and
# print the error message returned by the SMTP server:
begin
  draft.send!
rescue Nylas::APIError => e
  puts "Failed with error: #{e.message}"
  if not e.server_error.nil?
    puts "The SMTP server replied: #{e.server_error}"
  end
end
```

### Creating an event

```ruby
# Every event is attached to a calendar -- get the id of the first calendar
calendar_id = nylas.calendars.first.id
new_event = nylas.events.build(:calendar_id => calendar_id, :title => 'Coffee?')

# Modify attributes as necessary
new_event.location = "L'excelsior"

# Dates are expressed by the Inbox API as UTC timestamps
new_event.when = {:start_time => 1407542195, :end_time => 1407543195}

# Persist the event --- it's automatically synced back to the Google or Exchange calendar
new_event.save!

# Send an invite/update message to the participants
new_event.save!(:notify_participants => true)

# RSVP to an invite (Note: this only works for the events in the 'Emailed events' calendar)
# possible statuses are 'yes', 'no' and 'maybe'.
emailed_invite.rsvp!(status='yes', comment='I will come')
```

## Using the Delta sync API

The delta sync API allows fetching all the changes that occured after a specific time. [Read this](https://nylas.com/docs/platform/#deltas) for more details about the API.

```ruby
# Get an API cursor. Cursors are API objects identifying an individual change.
# The latest cursor is the id of the latest change which was applied
# to an API object (e.g: a message got read, an event got created, etc.)
cursor = nylas.latest_cursor

last_cursor = nil
nylas.deltas(cursor) do |event, object|
    if event == "create" or event == "modify"
        if object.is_a?(Nylas::Contact)
            puts "#{object.name} - #{object.email}"
        elsif object.is_a?(Nylas::Event)
            puts "Event!"
        end
    elsif event == "delete"
        # In the case of a deletion, the API only returns the ID of the object.
        # In this case, the Ruby SDK returns a dummy object with only the id field
        # set.
        puts "Deleting from collection #{object.class.name}, id: #{object}"
    end
    last_cursor = object.cursor
end

# Don't forget to save the last cursor so that we can pick up changes
# from where we left.
save_to_db(last_cursor)
```

### Using the Delta sync streaming API

The streaming API will receive deltas in real time, without needing to repeatedly poll. It uses EventMachine for async IO.

```ruby
cursor = nylas.latest_cursor

last_cursor = nil
nylas.delta_stream(cursor) do |event, object|
    if event == "create" or event == "modify"
        if object.is_a?(Inbox::Contact)
            puts "#{object.name} - #{object.email}"
        elsif object.is_a?(Inbox::Event)
            puts "Event!"
        end
    elsif event == "delete"
        # In the case of a deletion, the API only returns the ID of the object.
        # In this case, the Ruby SDK returns a dummy object with only the id field
        # set.
        puts "Deleting from collection #{object.class.name}, id: #{object}"
    end
    last_cursor = object.cursor

    # This will loop indefintely
end

```


### Exclude changes from a specific type --- get only messages

```ruby
nylas.deltas(cursor, exclude=[Nylas::Contact,
                              Nylas::Event,
                              Nylas::File,
                              Nylas::Tag,
                              Nylas::Thread]) do |event, object|
if event == 'create' or event == 'modify'
        puts object.subject
    end
end
```

### Expand Messages from the Delta stream

It's possible to ask the Deltas and delta stream API to return [expanded messages](https://nylas.com/docs/platform#expanded_message_view) directly:

```ruby
nylas.deltas(cursor, exclude=[Nylas::Contact,
                              Nylas::Event,
                              Nylas::File,
                              Nylas::Tag,
                              Nylas::Thread], expanded_view=true) do |event, object|
if event == 'create' or event == 'modify'
  if obj.is_a?(Inbox::Message)
      puts obj.subject
      puts obj.message_id
  end
end
```

### Handling Errors
The Nylas API uses conventional HTTP response codes to indicate success or failure of an API request. The ruby gem raises these as native exceptions.

Code | Error Type | Description
--- | --- | ---
400 | InvalidRequest | Your request has invalid parameters.
403 | AccessDenied | You don't have authorization to access the requested resource or perform the requested action. You may need to re-authenticate the user.
404 | ResourceNotFound | The requested resource doesn't exist.
500 | APIError | There was an internal error with the Nylas server.

A few additional exceptions are raised by the `draft.send!` method if your draft couldn't be sent.

Code | Error Type | Description
--- | --- | ---
402 | MessageRejected| The message was syntactically valid, but rejected for delivery by the mail server.
429 | SendingQuotaExceeded | The user has exceeded their daily sending quota.
503 | ServiceUnavailable | There was a temporary error establishing a connection to the user's mail server.



## Open-Source Sync Engine

The [Nylas Sync Engine](http://github.com/nylas/sync-engine) is open source, and you can also use the Ruby gem with the open source API. Since the open source API provides no authentication or security, connecting to it is simple. When you instantiate the Nylas object, provide `nil` for the App ID and App Secret, and set the API Token to the id of the account you're going to access. Finally, don't forget to pass the fully-qualified address to your copy of the sync engine:

```ruby
require 'nylas'
nylas = Nylas::API.new(nil, nil, nil, 'http://localhost:5555/')

# Get the id of the first account -- this is the access token we're
# going to use.
account_id = nylas.accounts.first.id

# Display the contents of the first message for the first account
nylas = Nylas::API.new(nil, nil, account_id, 'http://localhost:5555/')
puts nylas.messages.first.contents
```


## Contributing

We'd love your help making the Nylas ruby gem better. Join the Google Group for project updates and feature discussion. We also have a [Slack community](nylas-slack-invite.heroku.com) where we provide support, or you can email [support@nylas.com](mailto:support@nylas.com).

Please sign the [Contributor License Agreement](https://www.nylas.com/cla.html) before submitting pull requests. (It's similar to other projects, like NodeJS or Meteor.)

Tests can be run with:

    rspec spec


## Deployment

The Nylas ruby gem uses [Jeweler](https://github.com/technicalpickles/jeweler) for release management. Jeweler should be installed automatically when you call `bundle`, and extends `rake` to include a few more commands. When you're ready to release a new version, edit `lib/version.rb` and then build:

    rake inbox_build
    rake nylas_build

Test your new version (found in `pkg/`) locally, and then release with:

    rake inbox_release
    rake nylas_release

If it's your first time updating the ruby gems, you may be prompted for the username/password for rubygems.org. Members of the Nylas team can find that by doing `fetch-password rubygems`.

## API self-tests

Because it's critical that we don't break the SDK for our customers, we require releasers to run some tests before releasing a new version of the gem. The test programs are located in the test/ directory. To set up them up, you'll need to copy `tests/credentials.rb.templates` as `test/credentials.rb` and edit the `APP_ID` and `APP_SECRET` with a working Nylas API app id and secret. You also need to set up a `/callback` URL in the Nylas admin panel.

You can run the programs like this:
`cd tests && ruby -I../lib auth.rb`
`cd tests && ruby -I../lib system.rb`
