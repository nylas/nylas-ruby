# Rails App

You can run this sample app to see how to authenticate accounts with the Nylas API.

**Note:** To use the sample app you will need to

1. Replace the Nylas App ID and Secret in `config/environments/development.rb`
2. Add the Callback URL `http://localhost:3000/login_callback` to your app in the [developer console](https://developer.nylas.com/console)

```
cd examples/rails
bundle install
RESTCLIENT_LOG=stdout rails s
```