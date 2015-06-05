# Nylas REST API Ruby bindings

## Installation

Add this line to your application's Gemfile:

    gem 'inbox'

And then execute:

    bundle

You don't need to use this repo unless you're planning to modify the gem. If you just want to use the Inbox SDK with Ruby bindings, you should run:

    gem install inbox


##Requirements

- Ruby 1.8.7 or above. (Ruby 1.8.6 may work if you load ActiveSupport.)

- rest-client, json


## Example Rails App

A small example Rails app is included in the `example` directory. You can run the sample app to see how an authentication flow might be implemented.

`cd example`

`RESTCLIENT_LOG=stdout rails s`

*Note that you will need to replace the Inbox App ID and Secret in `config/environments/development.rb` to use the sample app.*

## Usage

### App ID and Secret

Before you can interact with the Inbox API, you need to register for the Nylas Developer Program at [https://www.nylas.com/](https://www.nylas.com/). After you've created a developer account, you can create a new application to generate an App ID / Secret pair.

Generally, you should store your App ID and Secret into environment variables to avoid adding them to source control. That said, in the example project and code snippets below, the values were added to `config/environments/development.rb` for convenience.


### Authentication

The Nylas REST API uses server-side (three-legged) OAuth, and the Ruby gem provides convenience methods that simplify the OAuth process. For more information about authenticating with Nylas, visit the [Developer Documentation](https://www.nylas.com/docs/knowledgebase#authentication).

**Step 1: Redirect the user to Nylas:**

```ruby
require 'inbox'

def login
  inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  # The email address of the user you want to authenticate
  user_email = 'ben@nylas.com'

  # This URL must be registered with your application in the developer portal
  callback_url = url_for(:action => 'login_callback')

  redirect_to inbox.url_for_authentication(callback_url, user_email)
end
```

**Step 2: Handle the Authentication Response:**

```ruby
def login_callback
  inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  inbox_token = inbox.token_for_code(params[:code])

  # Save the inbox_token to the current session, save it to the user model, etc.
end
```

### Managing Billing

If you're using the open-source version of the Nylas Sync Engine or have fewer than 10 accounts associated with your developer app, you don't need to worry about billing. However, if you've requested production access to the Sync Engine, you are billed monthly based on the number of email accounts you've connected to Inbox. You can choose to start accounts in "trial" state and sync slowly at a rate of one message per minute so users can try out your app. If you use trial mode, you need to upgrade accounts (and start paying for them) within 30 days or they will automatically expire. You may wish to upgrade accounts earlier to dramatically speed up the mail sync progress depending on your app's needs.

**Starting an Account in Trial Mode**

When you're redirecting the user to Nylas to authenticate with their email provider,
pass the additional `trial: true` option to start their account in trial mode.

```ruby
  redirect_to inbox.url_for_authentication(callback_url, user_email, {trial: true})
```

**Upgrading an Account**

```ruby
  inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  account = inbox.accounts.find(account_id)
  account.upgrade!
```

**Cancelling an Account**

```ruby
  inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  account = inbox.accounts.find(account_id)
  account.downgrade!

  # Your Inbox API token will be revoked, you will not be charged
```

### Account Status

````ruby
  # Query the status of every account linked to the app
  inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, inbox_token)
  accounts = inbox.accounts
  accounts.each { |a| [a.account_id, a.sync_state] } # Available fields are: account_id, sync_state, trial, trial_expires, billing_state and namespace_id. See lib/account.rb for more details.
```

### Fetching Namespaces

```ruby
inbox = Nylas::API.new(config.inbox_app_id, config.inbox_app_secret, inbox_token)

# Get the first namespace
namespace = inbox.namespaces.first

# Print out the email address and provider (Gmail, Exchange)
puts namespace.email_address
puts namespace.provider
```


### Fetching Threads

```ruby
# Fetch the first thread
thread = namespace.threads.first

# Fetch a specific thread
thread = namespace.threads.find('ac123acd123ef123')

# List all threads tagged `inbox`
# (paginating 50 at a time until no more are returned.)
namespace.threads.where(:tag => 'inbox').each do |thread|
  puts thread.subject
end

# List the 5 most recent unread threads
namespace.threads.where(:tag => 'unread').range(0,4).each do |thread|
  puts thread.subject
end

# List all threads with 'ben@nylas.com'
namespace.threads.where(:any_email => 'ben@nylas.com').each do |thread|
  puts thread.subject
end

# Get number of all threads
count = namespace.threads.count

# Get number of threads with 'ben@inboxapp.com'
count = namespace.threads.where(:any_email => 'ben@inboxapp.com').count

# Collect all threads with 'ben@nylas.com' into an array.
# Note: for large numbers of threads, this is not advised.
threads = namespace.threads.where(:any_email => 'ben@nylas.com').all
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

# Add or remove arbitrary tags
tagsToAdd = ['inbox', 'cfa1233ef123acd12']
tagsToRemove = []
thread.update_tags!(tagsToAdd, tagsToRemove)

# List messages
thread.messages.each do |message|
  puts message.subject
end
```


### Working with Files

```ruby
# List files
namespace.files.each do |file|
  puts file.filename
end

# Create a new file
file = namespace.files.build(:file => File.new("./public/favicon.ico", 'rb'))
file.save!
```

### Working with Messages, Contacts, etc.

Each of the primary collections (contacts, messages, etc.) behave the same way as `threads`. For example, finding messages with a filter is similar to finding threads:

```ruby
messages = namespace.messages.where(:to => 'ben@nylas.com`).all
```

The `where` method accepts a hash of filters, as documented in the [Inbox Filters Documentation](https://www.nylas.com/docs/api#filters).

### Getting the raw contents of a message

It's possible to access the unprocessed contents of a message using the raw method:

```ruby
raw_contents = message.raw.rfc2822
```


### Creating and Sending Drafts

```ruby
# Create a new draft
draft = namespace.drafts.build(
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
```

### Creating an event

````ruby
# Every event is attached to a calendar -- get the id of the first calendar
calendar_id = inbox.namespaces.first.calendars.first.id
new_event = inbox.namespaces.first.events.build(:calendar_id => calendar_id, :title => 'Coffee?')

# Modify attributes as necessary
new_event.location = "L'excelsior"

# Dates are expressed by the Inbox API as UTC timestamps
new_event.when = {:start_time => 1407542195, :end_time => 1407543195}

# Persist the event --- it's automatically synced back to the Google or Exchange calendar
new_event.save!
```

## Using the Delta sync API

The delta sync API allows fetching all the changes that occured since a specified time. [Read this](https://nylas.com/docs/api#sync-protocol) for more details about the API.

````ruby
# Get all the messages starting from timestamp
#
# we first need to get a cursor object a cursor is simply the id of
# an individual change.
cursor = inbox.namespaces.first.get_cursor(1407543195)

last_cursor = nil
inbox.namespaces.first.deltas(cursor) do |event, object|
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

### Exclude changes from a specific type --- get only messages
````ruby
inbox.namespaces.first.deltas(cursor, exclude=[Nylas::Contact,
                                               Nylas::Event,
                                               Nylas::File,
                                               Nylas::Tag,
                                               Nylas::Thread]) do |event, object|
if event == 'create' or event == 'modify'
        puts object.subject
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

The [Nylas Sync Engine](http://github.com/inboxapp/inbox) is open-source, and you can also use the Ruby gem with the open-source API. Since the open-source API provides no authentication or security, connecting to it is simple. When you instantiate the Inbox object, provide `nil` for the App ID, App Secret, and API Token, and pass the fully-qualified address to your copy of the sync engine:

```ruby
require 'inbox'
inbox = Nylas::API.new(nil, nil, nil, 'http://localhost:5555/')
```


## Contributing

We'd love your help making the Nylas ruby gem better. Join the Google Group for project updates and feature discussion. We also hang out in `#Nylas` on [irc.freenode.net](http://irc.freenode.net), or you can email [support@nylas.com](mailto:support@nylas.com).

Please sign the [Contributor License Agreement](https://www.nylas.com/cla.html) before submitting pull requests. (It's similar to other projects, like NodeJS or Meteor.)

Tests can be run with:

    rspec spec


## Deployment

The Nylas ruby gem uses [Jeweler](https://github.com/technicalpickles/jeweler) for release management. Jeweler should be installed automatically when you call `bundle`, and extends `rake` to include a few more commands. When you're ready to release a new version, edit `lib/version.rb` and then build:

    rake build

Test your new version (found in `pkg/`) locally, and then release with:

    rake release

If it's your first time updating the ruby gem, you may be prompted for the username/password for rubygems.org. Members of the Nylas team can find that by doing `fetch-password rubygems`.

## OAuth self-test

Because it's very important that we don't break OAuth, we require releasers to run the OAuth self-test before releasing a version of the gem. The self-test is a small sinatra program which will ask you to click on a couple URLs. You need to make sure that following the URLs return a working token.

To set up the program, you need to copy `tests/credentials.rb.templates` as `test/credentials.rb` and edit the `APP_ID` and `APP_SECRET` with a working Nylas API app id and secret. You also need to set up a `/callback` URL in the Nylas admin panel.

You can then run the program using `cd tests && ruby -I../lib auth.rb`
