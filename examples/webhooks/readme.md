# Nylas Webhooks

This tiny sinatra app is a simple example of how to use Nylas' webhooks feature
with ruby.  This app correctly responds to Nylas' challenge request when you add
a webhook url to the [developer dashboard](https://developer.nylas.com). It also
verifies any webhook notification POST requests by Nylas and prints out some
information about the notification.
 
# Dependencies

## ngrok

[ngrok](https://ngrok.com/) makes it really easy to test callback urls that are
running locally on your computer. 

# Initial Setup

Add your `nylas_client_secret` to `config.yml`. Then install dependencies with:

```bash
bundle install
```

# Running the app

First, make sure ngrok is running with the same port that the local sinatra app
is running.

```bash
ngrok http 1234
```

Next, run the sinatra app.

```bash
ruby app.py
```

Follow the instructions that are printed to the console.
