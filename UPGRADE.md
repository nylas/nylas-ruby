# Upgrading to Nylas Ruby SDK v6.0

The Nylas Ruby SDK has been refactored and large parts of it have been rewritten for the upcoming release of the Nylas API v3. The goal was to have a product that is intuitive and easier to use. This guide will help you upgrade your code to use the new SDK. The new SDK also includes [documentation for the SDK's methods and usage](https://nylas-ruby-sdk-reference.pages.dev/) so you can easily find the implementation details you need.

⚠️ **Note:** The Nylas Ruby SDK v6.0 is not compatible with Nylas APIs earlier than 3.0 beta. If you are still using an earlier version of the API (such as Nylas v2.7), keep using the Nylas Ruby SDK v5.x until you can upgrade.

## Initial Set up

To upgrade to the new SDK, you update your dependencies to use the new version. This can be done by installing the new version of the SDK using RubyGems.

**Note:** There is a minimum Ruby version has been moved up to the lowest supported LTS, Ruby v3.0.

```bash
gem install nylas --pre
```
The first step to using the new SDK is to initialize a new instance of the Nylas SDK. This is done by passing in your API key to the constructor. You 
will notice the change here.

```ruby
require 'nylas'

nylas = Nylas::API.new(
  api_key: "NYLAS_APP_KEY",
)
```

From here, you can use the `Nylas` instance to make API requests by accessing the different resources configured with your API Key.

## Making Requests to the Nylas API

The `Nylas` instance that was configured earlier is used to make requests to the Nylas API. The SDK is organized into different resources, each of which has all the available methods to make requests to the API.

For example, to get a list of calendars, you can do so like:
```ruby
require 'nylas'

nylas = Nylas::API.new(
  api_key: "NYLAS_APP_KEY",
)

events, _request_ids = nylas.events.list(identifier: "grant_id")
```

You might notice in the code above that there are some new concepts in the new SDK when making requests. These concepts are explained in more detail below.

### Resource Parameters

Each resource takes different parameters. All resources take an "identifier", which is the ID of the account you want to make the request for. This is usually the Grant ID or the email address of the account. Some resources also take "query parameters" which are mainly used to filter data or pass in additional information.

### Response Objects

The Nylas API returns a JSON response for each request. The SDK parses the JSON response and returns a response hash that contains the data returned from the API a string representing the request ID for the request that was made. This ID is used for debugging purposes.

For List requests, the same applies, except the response hash contains an array of the data returned from the API. Furthermore, if there's another page of data, the response hash will contain a `next_cursor` key that contains a token representing the next page of data. Currently there's no direct support for pagination, however you can extract this token and use it as a query parameter for the next request to get the next page of data.

### Error Objects

Like the response objects, Nylas v3 now has standard error objects for all requests (excluding OAuth endpoints). There are two superclass error classes, `AbstractNylasApiError`, used for errors returned by the API, and `AbstractNylasSdkError`, used for errors returned by the SDK.

The `AbstractNylasApiError` includes two subclasses: `NylasOAuthError`, used for API errors that are returned from the OAuth endpoints, and `NylasApiError`, used for any other Nylas API errors.

The error details are extracted from the response and stored in the error object along with the request ID and the HTTP status code.

`AbstractNylasSdkError` is used for errors returned by the SDK. Right now there's only one type of error we return, and that's a `NylasSdkTimeoutError` which is thrown when a request times out.

Putting it all together, the following code shows how to make a request to create a new Event and handle any errors that may occur:

```ruby
require 'nylas'

nylas = Nylas::API.new(
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
rescue Nylas::NylasApiError => e
  # Handle the error
  puts e.message
  puts e.request_id
  puts e.status_code
rescue Nylas::NylasSdkTimeoutError => e
  # Handle the error
  puts e.message
  puts e.url
end
```

## Authentication

The available authentication methods reflect the new Nylas API v3. While you can manage your application's integrations in the dashboard, you can manage almost everything else directly from the SDK. This includes managing grants, redirect URIs, OAuth tokens, and authenticating your users.

There are two main methods to focus on when authenticating users to your application. The first is the `Auth#urlForOAuth2` method, which returns the URL that you should redirect your users to in order to authenticate them using Nylas' OAuth 2.0 implementation.

The second is the `Auth#exchangeCodeForToken` method, which you use to exchange the code returned from the authentication redirect for an access token. You actually don't need to use the data from the response as you can use the authenticated email address directly as the identifier for the account. However, if you prefer to use the grant ID as the account identifier, you can extract the grant ID from the `CodeExchangeResponse` object and use that instead.

The following code shows how to authenticate a user into a Nylas application:

```ruby
require 'nylas'

nylas = Nylas::API.new(
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
