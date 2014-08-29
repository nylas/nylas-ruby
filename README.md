# Inbox Ruby bindings

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

Before you can interact with the Inbox API, you need to register for the Inbox Developer Program at [http://www.inboxapp.com/](http://www.inboxapp.com/). After you've created a developer account, you can create a new application to generate an App ID / Secret pair.

Generally, you should store your App ID and Secret into environment variables to avoid adding them to source control. That said, in the example project and code snippets below, the values were added to `config/environments/development.rb` for convenience.


### Authentication

The Inbox API uses server-side (three-legged) OAuth, and the Ruby gem provides convenience methods that simplify the OAuth process. For more information about authenticating with Inbox, visit the [Developer Documentation](https://www.inboxapp.com/docs/gettingstarted-hosted#authenticating).

**Step 1: Redirect the user to Inbox:**

```ruby
require 'inbox'

def login
  inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  # The email address of the user you want to authenticate
  user_email = 'ben@inboxapp.com'

  # This URL must be registered with your application in the developer portal
  callback_url = url_for(:action => 'login_callback')
  
  redirect_to inbox.url_for_authentication(callback_url, user_email)
end
```

**Step 2: Handle the Authentication Response:**

```ruby
def login_callback 
  inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, nil)
  inbox_token = inbox.token_for_code(params[:code])

  # Save the inbox_token to the current session, save it to the user model, etc.
end
```

### Fetching Namespaces

```ruby
inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, inbox_token)

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

# List all threads with 'ben@inboxapp.com'
namespace.threads.where(:any_email => 'ben@inboxapp.com').each do |thread|
  puts thread.subject
end    

# Collect all threads with 'ben@inboxapp.com' into an array.
# Note: for large numbers of threads, this is not advised.
threads = namespace.threads.where(:any_email => 'ben@inboxapp.com').all
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
messages = namespace.messages.where(:to => 'ben@inboxapp.com`).all
```

The `where` method accepts a hash of filters, as documented in the [Inbox Filters Documentation](https://www.inboxapp.com/docs/api#filters). 

### Creating and Sending Drafts

```ruby
# Create a new draft
draft = namespace.drafts.build(
  :to => [{:name => 'Ben Gotow', :email => 'ben@inboxapp.com'}],
  :subject => "Sent by Ruby",
  :body => "Hi there!<strong>This is HTML</strong>"
)

# Modify attributes as necessary
draft.cc = [{:name => 'Michael', :email => 'mg@inboxapp.com'}]

# Add the file we uploaded as an attachment
draft.attach(file)

# Save the draft
draft.save!

# Send the draft. This method returns immediately and queues the message
# with Inbox for delivery through the user's SMTP gateway.
draft.send!
```

## Open-Source Sync Engine

The [Inbox Sync Engine](http://github.com/inboxapp/inbox) is open-source, and you can also use the Ruby gem with the open-source API. Since the open-source API provides no authentication or security, connecting to it is simple. When you instantiate the Inbox object, provide nil for the App ID, App Secret, and API Token, and pass the fully-qualified address to your copy of the sync engine:

```ruby
require 'inbox'
inbox = Inbox::API.new(nil, nil, nil, 'http://localhost:5555/')
```


## Contributing

We'd love your help making the Inbox ruby gem better. Join the Google Group for project updates and feature discussion. We also hang out in `##inbox` on [irc.freenode.net](http://irc.freenode.net), or you can email [help@inboxapp.com](mailto:help@inboxapp.com).

Please sign the Contributor License Agreement before submitting pull requests. (It's similar to other projects, like NodeJS or Meteor.)

The Inbox ruby gem uses [Jeweler](https://github.com/technicalpickles/jeweler) for release management. When you're ready to release a new version, do something like this:

    rake version:bump:minor
    rake release

Tests can be run with:

    rspec spec

