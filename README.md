<a href="https://www.nylas.com/">
    <img src="https://brand.nylas.com/assets/downloads/logo_horizontal_png/Nylas-Logo-Horizontal-Blue_.png" alt="Aimeos logo" title="Aimeos" align="right" height="60" />
</a>

# Nylas Ruby SDK

[![Gem (including prereleases)](https://img.shields.io/gem/v/nylas?include_prereleases)](https://rubygems.org/gems/nylas)
[![codecov](https://codecov.io/gh/nylas/nylas-ruby/branch/main/graph/badge.svg?token=IKH0YMH4KA)](https://codecov.io/gh/nylas/nylas-ruby)

This is the GitHub repository for the Nylas Ruby SDK. This repo is primarily for anyone who wants to make contributions to the SDK or install it from source. For documentation on how to use this SDK to access the Nylas Email, Calendar, or Contacts APIs, see the official [Ruby SDK Quickstart Guide](https://developer.nylas.com/docs/sdks/ruby/).

The Nylas Communications Platform provides REST APIs for [Email](https://developer.nylas.com/docs/email/), [Calendar](https://developer.nylas.com/docs/calendar/), and [Contacts](https://developer.nylas.com/docs/contacts/), and the Nylas SDK is the quickest way to build your integration using Kotlin or Java.

Here are some resources to help you get started:

- [Sign up for your free Nylas account](https://dashboard.nylas.com/register)
- [Nylas API v3 Quickstart Guide](https://developer.nylas.com/docs/v3-beta/v3-quickstart/)
- [Nylas SDK Reference](https://nylas-ruby-sdk-reference.pages.dev/)
- [Nylas API Reference](https://developer.nylas.com/docs/api/)
- [Nylas Samples repo for code samples and example applications](https://github.com/orgs/nylas-samples/repositories?q=&type=all&language=ruby)

If you have a question about the Nylas Communications Platform, [contact Nylas Support](https://support.nylas.com/) for help.

## ⚙️ Install
### Prerequisites
- Ruby 3.0 or above.
- Ruby Frameworks: `rest-client` and `yajl-ruby`.

### Install

Add this line to your application's Gemfile:

```ruby
gem 'nylas'
```

And then execute:

```bash
bundle
```

To run scripts that use the Nylas Ruby SDK, install the nylas gem.

```bash
gem install nylas
```

To install the SDK from source, clone this repo and install with bundle.

```bash
git clone https://github.com/nylas/nylas-ruby.git && cd nylas-ruby
bundle install
```

### Setup Ruby SDK for Development

Install [RubyGems](https://rubygems.org/pages/download) if you don't already have it:

```shell
gem install bundler
gem update --system
```

Install the SDK from source

```shell
bundle install
```

You can run tests locally using ```rspec```:

```shell
rspec spec
```

## ⚡️ Usage

To use this SDK, you must first [get a free Nylas account](https://dashboard.nylas.com/register).

Then, follow the Quickstart guide to [set up your first app and get your API keys](https://developer.nylas.com/docs/v3-beta/v3-quickstart/).

For code examples that demonstrate how to use this SDK, take a look at our [Ruby repos in the Nylas Samples collection](https://github.com/orgs/nylas-samples/repositories?q=&type=all&language=ruby).

### 🚀 Making Your First Request

All of the functionality of the Nylas Communications Platform is available through the `Client` object. To access data for an account that’s connected to Nylas, create a new API client object and pass in your Nylas API key. In the following example, replace `NYLAS_API_KEY` with your Nylas API Key, and you can provide other additional configurations such as the Nylas API url and the timeout.

```ruby
require 'nylas'

nylas = Nylas::Client.new(
  api_key: "NYLAS_API_KEY",
)
```

Now, you can use `nylas` to access full email, calendar, and contacts functionality, for example to list all the calendars for a given account:

```ruby
calendars, _request_ids = nylas.calendars.list(identifier: "GRANT_ID")
```

## 📚 Documentation

Nylas maintains a [reference guide for the Ruby SDK](https://nylas-ruby-sdk-reference.pages.dev/) to help you get familiar with the available methods and classes.

## ✨ Upgrading from 5.x

See [UPGRADE.md](UPGRADE.md) for instructions on upgrading from 5.x to 6.x.

**Note**: The Ruby SDK v6.x is not compatible with the Nylas API earlier than v3-beta.

## 💙 Contributing

Please refer to [Contributing](Contributing.md) for information about how to make contributions to this project. We welcome questions, bug reports, and pull requests.

## 📝 License

This project is licensed under the terms of the MIT license. Please refer to [LICENSE](LICENSE.txt) for the full terms. 
