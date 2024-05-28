# Upgrading to Nylas Ruby SDK v6.0

The Nylas Ruby SDK has been refactored and large parts of it have been rewritten for the upcoming release of the [Nylas API v3](https://developer.nylas.com/docs/v3-beta/). The goal was to have a product that is intuitive and easier to use. This guide helps you upgrade your code to use the new SDK. The new SDK also includes [documentation for the SDK's methods and usage](https://nylas-ruby-sdk-reference.pages.dev/) so you can easily find the implementation details you need.

Head's up! Nylas API v3 [contains a lot of changes](https://developer.nylas.com/docs/v3-beta/features-and-changes/), and you should familiarize yourself with them before you start upgrading.

⚠️ **Note:** The Nylas Ruby SDK v6.0 is not compatible with Nylas APIs earlier than 3.0 beta. If you are still using an earlier version of the API (such as Nylas v2.7), keep using the Nylas Ruby SDK v5.x until you can upgrade.

## Initial Set up

To upgrade to the new SDK, update your dependencies to use the new version. You do this by using RubyGems to install the new version of the SDK.

**Note:** The minimum Ruby version is now at the oldest supported LTS, Ruby v3.0.

```bash
gem install nylas --pre
```

The first step to using the new SDK is to initialize a new instance of the Nylas SDK. Do this by passing in your API key to the constructor. Notice the syntax change in the example below.

```ruby
require 'nylas'

nylas = NylasV2::API.new(
  api_key: "NYLAS_API_KEY",
)
```

From here, you can use the `Nylas` instance to make API requests using your API key to access the different resources.

## Making Requests to the Nylas API

You use the `Nylas` instance that you configured earlier to make requests to the Nylas API. The SDK is organized into different resources for each of the Email, Calendar, and Contacts APIs, and each resource has all the available methods to make requests to the API.

For example, to get a list of calendars, you can do so like:

```ruby
require 'nylas'

nylas = NylasV2::API.new(
  api_key: "NYLAS_API_KEY",
)

events, _request_ids = nylas.events.list(identifier: "grant_id")
```

You might notice that there are some new concepts in the example SDK code above when making requests. These concepts are explained in more detail below.

### Resource Parameters

Each resource takes different parameters. All resources take an "identifier", which is the ID of the account you want to make the request on behalf of. This is usually the Grant ID or the email address of the account. Some resources also take "query parameters" which are mainly used to filter data or pass in additional information.

### Response Objects

The Nylas API returns a JSON response for each request. The SDK parses the JSON response and returns a response hash that contains the data returned from the API, and a string that represents the request ID for the request it responds to. You can use this ID for debugging and troubleshooting.

List request responses include the same items, except the response hash contains an _array_ of the data returned from the API. If there are multiple pages of data, the response hash also contains a `next_cursor` key that includes a token that represents the next page of data. You can extract this token and use it as a query parameter for the next request to get the next page of data. Pagination features are coming soon.

### Error Objects

Like the response objects, Nylas v3 now has standard error objects for all requests (excluding OAuth endpoints, see below). There are two superclass error classes, `AbstractNylasApiError`, used for errors returned by the API, and `AbstractNylasSdkError`, used for errors returned by the SDK.

The `AbstractNylasApiError` includes two subclasses: `NylasOAuthError`, used for API errors that are returned from the OAuth endpoints, and `NylasApiError`, used for any other Nylas API errors.

The SDK extracts the error details from the response and stores them in the error object, along with the request ID and the HTTP status code.

`AbstractNylasSdkError` is used for errors returned by the SDK. Right now there's only one type of error we return, and that's a `NylasSdkTimeoutError` which is thrown when a request times out.

Putting it all together, the following example code shows how to make a request to create a new Event and handle any errors that may occur:

```ruby
require 'nylas'

nylas = NylasV2::API.new(
  api_key: "NYLAS_APP_KEY",
)

begin
  # Build the create event request
  create_event_request = nylas.events.create(
    identifier: "GRANT_ID",
    query_params: {
      calendar_id: "CALENDAR_ID", # A calendar ID is required
    },
    request_body: {
      when: {
        start_time: 1686765600,
        end_time: 1686769200,
      }, # A "When" type is required
      title: "My Event", # Title is optional
      description: "My event description", # Description is optional
      location: "My event location", # Location is optional
    }
  )
rescue NylasV2::NylasApiError => e
  # Handle the error
  puts e.message
  puts e.request_id
  puts e.status_code
rescue NylasV2::NylasSdkTimeoutError => e
  # Handle the error
  puts e.message
  puts e.url
end
```

## Authentication

The SDK's authentication methods reflect [the methods available in the new Nylas API v3](https://developer.nylas.com/docs/developer-guide/v3-authentication/). While you can only create and manage your application's connectors (formerly called integrations) in the dashboard, you can manage almost everything else directly from the SDK. This includes managing grants, redirect URIs, OAuth tokens, and authenticating your users.

There are two main methods to focus on when authenticating users to your application. The first is the `Auth#urlForOAuth2` method, which returns the URL that you redirect your users to in order to authenticate them using Nylas' OAuth 2.0 implementation.

The second is the `Auth#exchangeCodeForToken` method. Use this method to exchange the code Nylas returned from the authentication redirect for an access token from the OAuth provider. Nylas's response to this request includes both the access token, and information about the grant that was created.  You don't _need_ to use the `grant_id` to make requests. Instead, you can use the authenticated email address directly as the identifier for the account. If you prefer to use the `grant_id`, you can extract it from the `CodeExchangeResponse` object and use that instead.

The following code shows how to authenticate a user into a Nylas application:

```ruby
require 'nylas'

nylas = NylasV2::API.new(
  api_key: "NYLAS_APP_KEY",
)

# Build the URL for authentication
auth_url = nylas.auth.url_for_oauth2(
  client_id: "CLIENT_ID",
  redirect_uri: "REDIRECT_URI",
  login_hint: "example@email.com"
)

# Write code here to redirect the user to the url and parse the code
...

# Exchange the code for an access token

code_exchange_response = nylas.auth.exchange_code_for_token({
  redirect_uri: "REDIRECT_URI",
  client_id: "CLIENT_ID",
  client_secret: "CLIENT_SECRET",
  code: "CODE"
})

# Now you can either use the email address that was authenticated or the grant ID in the response as the identifier

response_with_email = nylas.calendars.list(
  identifier: "example@email.com"
)

response_with_grant = nylas.calendars.list(
  identifier: code_exchange_response.grant_id
)
```
