# Nylas REST API Ruby bindings ![Travis build status](https://travis-ci.org/nylas/nylas-ruby.svg?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/26d5b58447ca8bf213df/maintainability)](https://codeclimate.com/github/nylas/nylas-ruby/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/26d5b58447ca8bf213df/test_coverage)](https://codeclimate.com/github/nylas/nylas-ruby/test_coverage)

This README is for the Nylas Ruby SDK version 4. For those who are still using Nylas Ruby SDK Version 3, the documentation and source code is located in the [3.X-master branch](https://github.com/nylas/nylas-ruby/tree/3.X-master). For those upgrading from 3.X to 4.0, review the [upgrade guide](https://github.com/nylas/nylas-ruby/wiki/Upgrading-from-3.X-to-4.0)

## Installation

Add this line to your application's Gemfile:

    gem 'nylas'

And then execute:

    bundle

You don't need to use this repo unless you're planning to modify the gem. If you just want to use the Nylas SDK with Ruby bindings, you should run:

    gem install nylas

### MacOS 10.11 (El Capitan) note

Apple stopped bundling openssl with MacOS 10.11. However, one of the dependencies of this gem (EventMachine) requires it. If you're on El Capitan and are unable to install the gem, try running the following commands in a terminal:

```
sudo brew install openssl
sudo brew link openssl --force
gem install nylas
```

## Requirements

- Ruby 2.2.2 or above.
- rest-client, json, yajl-ruby, em-http-request

### Supported Rails Versions

We support Rails 4.2 and above. A more detailed compatiblity list can be found in our [list of Gemfiles](gemfiles)

## Examples

Examples are located in the [examples](./examples) directory. Examples in plain ruby are in [examples/plain-ruby/](./examples/plain-ruby). They are grouped by the API endpoints they interact with.

### Handling Errors
The Nylas API uses conventional HTTP response codes to indicate success or failure of an API request. The ruby gem raises these as native exceptions.

Code | Error Type | Description
--- | --- | ---
400 | `InvalidRequest` | Your request has invalid parameters.
403 | `AccessDenied` | You don't have authorization to access the requested resource or perform the requested action. You may need to re-authenticate the user.
404 | `ResourceNotFound` | The requested resource doesn't exist.
500 | `InternalError` | There was an internal error with the Nylas server.
502 | `BadGateway` | Nylas received an invalid response from the upstream server.

A few additional exceptions are raised by the `draft.send!` method if your draft couldn't be sent.

Code | Error Type | Description
--- | --- | ---
402 | `MessageRejected` | The message was syntactically valid, but rejected for delivery by the mail server.
422 | `MailProviderError` | There was an error with the mail provider when trying to send the message
429 | `SendingQuotaExceeded` | The user has exceeded their daily sending quota.
503 | `ServiceUnavailable` | There was a temporary error establishing a connection to the user's mail server.

## Open-Source Sync Engine

The [Nylas Sync Engine](http://github.com/nylas/sync-engine) is open source, and you can also use the Ruby gem with the open source API. Since the open source API provides no authentication or security, connecting to it is simple. When you instantiate the Nylas object, provide `nil` for the App ID and App Secret, and set the API Token to the id of the account you're going to access. Finally, don't forget to pass the fully-qualified address to your copy of the sync engine:

```ruby
require 'nylas'
nylas = Nylas::API.new(api_server: 'http://localhost:5555/')

# Get the id of the first account -- this is the access token we're
# going to use.
account_id = nylas.accounts.first.id

# Display the body of the first message for the first account
nylas = Nylas::API.new(access_token: account_id, api_server: 'http://localhost:5555/')
puts nylas.messages.first.body
```

## Development

### Requirements

Install [RubyGems](https://rubygems.org/pages/download) if you don't have it

    gem install bundler
    gem update --system

### Setup

    bundle install

You can run tests locally using rspec

    rspec spec


## Contributing

Our guidelines for contributing are in [CONTRIBUTING.md](./CONTRIBUTING.md).
