This example application listens for webhook events and logs them directly to
the screen, first as the entire JSON blob that is received, then as each Delta,
then as the particular data as a hash

## Running the Example

1. Clone the repository
1. Install the dependencies by using `bundle install`
1. Get a Nylas App ID and App Secret from the [Nylas Dashboard](https://dashboard.nylas.com/)
1. Run the app web server: `bundle exec ruby demo-app.rb`
1. Use a service like `ngrok` to expose your local app server to the public internet.
1. Set up a webhook to point to the public url for your local instance at the path `/webhook-event-received` by following the [instructions for creating a webhook](https://docs.nylas.com/v1.0/reference#creating-a-webhook).
1. Perform some kind of interactions that would trigger the webhook.
