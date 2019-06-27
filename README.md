# Nylas Ruby SDK 

The Nylas Ruby SDK provides all of the functionality of the Nylas [REST API](https://docs.nylas.com/reference) in an easy-to-use Ruby API. With the SDK, you can programmatically access an email account (e.g. Gmail, Yahoo, etc.) and perform functionality such as getting messages and listing message threads.

This README is for Nylas Ruby SDK version 4. For those who are still using Nylas Ruby SDK Version 3, the documentation and source code are located in the [3.X-master branch](https://github.com/nylas/nylas-ruby/tree/3.X-master). For those upgrading from 3.X to 4.0, review the [upgrade guide](https://github.com/nylas/nylas-ruby/wiki/Upgrading-from-3.X-to-4.0).

# Table of Contents

* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
* [Quick Start](#quick-start)
* [Handling Errors](#handling-errors)
* [Open-Source Sync Engine](#open-source-sync-engine)
* [Development](#development)
* [Contributing to the Nylas Ruby SDK](#contributing-to-the-nylas-ruby-sdk)

# Requirements

- Ruby 2.3 or above.
- Ruby Frameworks: ```rest-client```, ```json```, ```yajl-ruby```, ```em-http-request```.

## Supported Rails Versions

We support Rails 4.2 and above. A more detailed compatibility list can be found in our [list of Gemfiles](gemfiles).

# Install

Add this line to your application's Gemfile:

```shell
gem 'nylas'
```

And then execute:

```shell
bundle
```

You don't need to use this repository unless you're planning to modify the gem. If you just want to use the Nylas SDK with Ruby bindings, simply run:

```shell
gem install nylas
```

## MacOS 10.11 (El Capitan) Note

Apple stopped bundling OpenSSL with MacOS 10.11. However, one of the dependencies of this gem (EventMachine) requires it. If you're on El Capitan and are unable to install the gem, try running the following commands in a terminal:

```
sudo brew install openssl
sudo brew link openssl --force
gem install nylas
```

# Usage

Every resource (i.e. messages, events, contacts, etc.) is accessed via an instance of ```Nylas::API```. Before making any requests, call ```new``` and initialize the Nylas instance with your APP ID and APP Secret. Then, call ```authenticate``` followed by ```as``` and pass it your access token. The access token allows Nylas to make requests for a given email account's resources.

```ruby
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'])

nylas_token = api.authenticate(name: auth_hash[:info][:name], 
        email_address: auth_hash[:info][:email], 
        provider: :gmail, 
        settings: 
            { google_client_id: ENV['GOOGLE_CLIENT_ID'], 
          google_client_secret: ENV['GOOGLE_CLIENT_SECRET'],
          google_refresh_token: auth_hash[:credentials][:refresh_token] })
api_as_user = api.as(nylas_token)
```

You can then use the API to access the account. The following example retrieves the first email in an account:

```ruby
an_email = api_as_user.messages.first
```

# Quick Start

A quick start tutorial on how to get up and running with the SDK is available [here](https://docs.nylas.com/docs/ruby-quick-start).

# Handling Errors
The Nylas API uses conventional HTTP response codes to indicate success or failure of an API request. The Ruby gem raises these as native exceptions. For a complete list response codes see: [Errors](https://docs.nylas.com/reference#errors).

# Open-Source Sync Engine

The [Nylas Sync Engine](http://github.com/nylas/sync-engine) is open source, and you can also use the Ruby gem with the open source API. Since the open source API provides no authentication or security, connecting to it is simple. When you instantiate the Nylas object, set the App ID and App Secret to `nil`, and set the API Token to the ID of the account you're going to access. 

Finally, pass the fully-qualified address to your copy of the sync engine:

```ruby
require 'nylas'
nylas = Nylas::API.new(api_server: 'http://localhost:5555/')

# Get the ID of the first account -- this is the access token we're
# going to use.
account_id = nylas.accounts.first.id

# Display the body of the first message for the first account
nylas = Nylas::API.new(access_token: account_id, api_server: 'http://localhost:5555/')
puts nylas.messages.first.body
```

# Development

## Requirements

Install [RubyGems](https://rubygems.org/pages/download) if you don't already have it:

```shell
gem install bundler
gem update --system
```

## Set Up

```shell
bundle install
```

You can run tests locally using ```rspec```:

```shell
rspec spec
```

# Contributing to the Nylas Ruby SDK

We'd love your help making the Nylas ruby gem better. You can email us at [support@nylas.com](mailto:support@nylas.com) if you have any questions, or join us at our community Slack channel [here](http://slack-invite.nylas.com).

Please sign the [Contributor License Agreement](https://goo.gl/forms/lKbET6S6iWsGoBbz2) before submitting pull requests (it's similar to other projects, like NodeJS, or Meteor).

### Getting the Code Running Locally

The `bin/setup` script installs the different Ruby versions that the gem is expected to run on. Right now it's optimized for ```rbenv``` and Unix operating systems; support to make it play nicely with ```rvm``` and/or Windows would be appreciated!

### Submitting a Pull Request

* Pull requests *may* be submitted before they are feature complete to get feedback and thoughts from the core team.
* Pull requests *should* pass tests across the supported versions of Ruby, as defined in [.travis.yml](./.travis.yml). To do so, run `bin/test`.
* Pull requests *should* add new tests to cover the functionality that is added or a bug that is fixed.

### Releasing Gems

#### API self-tests

Since it's critical that we don't break the SDK for our customers, we require releases to run some tests before releasing a new version of the gem. The test programs are located in the ```examples/``` directory. To set up them up, you'll need to copy `.env.example` to `.env` and edit it to provide real credentials.

You can run the basic examples like this:
```shell
dotenv ruby examples/plain-ruby.rb # Execute the examples in plain old ruby
```
To manually check that the authentication features still work, follow the instructions in `[examples/authentication/README.md](examples/authentication/README.md)`.

#### Authenticating to RubyGems

Nylas team members can authenticate with the following command:

```
curl -u nylas https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials
```

#### Pushing to Rubygems

Once the tests all pass, you're ready to release a new version!
Update `lib/nylas/version.rb` to the next planned release version then run:

```
bin/test
bin/release
```
