# Authentication

Nylas supports two forms of authentication:

* Native Authentication, where the developer is responsible for building the user interface for retrieiving the appropriate credentials for a users contacts, mail and/or calendar provider. See the [Nylas Native Authentication Reference Documentation](https://docs.nylas.com/reference#native-authentication-1) for more details.

* Nylas OAuth, where Nylas acts as an OAuth Provider that abstracts away the supported providers. This allows you to get up and running quickly without having to build potentially complex user interfaces for supporting any number of providers. See the [Nylas OAuth Authentication Reference Documentation](https://docs.nylas.com/reference#oauth) for more details.

## Running the Example

1. Clone the repository
1. Install the dependencies by using `bundle install`
1. Get a Nylas App ID and App Secret fromt he [Nylas Dashboard](https://dashboard.nylas.com/)
1. Get a Google Cloud Platform Access Token by following the [Nylas Google OAuth Setup Guide](https://support.nylas.com/hc/en-us/articles/222176307)
1. Use [Ngrok](https://ngrok.com/) or similar to forward a public domain to your local port 4578
1. Copy `.env.example` to `.env` and set the values based upon the previous steps.
1. Run the app web server: `bundle exec dotenv ruby app.rb`
1. Visit your public ngrok domain in your browser
1. Login to whichever mail, contact, and calendaring providers you want using the different authentication mechanisms.
1. Behold the power of this fully operational communication platform!

