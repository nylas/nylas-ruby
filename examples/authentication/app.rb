require 'pry'
require 'nylas'
require 'sinatra'
require 'omniauth'
require 'omniauth-google-oauth2'

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
    { name: 'google', access_type: :offline, approval_prompt: "force", prompt: 'consent',
      scope: ['email', 'profile', 'https://mail.google.com/',
              'https://www.google.com/m8/feeds/',
              'calendar'].join(', ') }
end
get "/" do
  '<a href="/auth/google">Authenticate a Google Account</a>'
end

get "/auth/failure" do
  params[:message]
end

%w(get post).each do |method|
  send(method, "/auth/:provider/callback") do
    auth_hash = env['omniauth.auth'] # => OmniAuth::AuthHash

    api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'])
    nylas_token = api.authenticate(name: auth_hash[:info][:name], email_address: auth_hash[:info][:email],
                                   provider: :gmail,
                                   settings: { google_client_id: ENV['GOOGLE_CLIENT_ID'],
                                               google_client_secret: ENV['GOOGLE_CLIENT_SECRET'],
                                               google_refresh_token: auth_hash[:credentials][:refresh_token] })

    api_as_user = api.as(nylas_token)

    an_email = api_as_user.messages.first

    # Revoke the nylas access token so it cannot be used in the future (you probably don't want to do this
    # unless people deactivate their account with your software)
    api.revoke(nylas_token)

    "An email you've received has the subject #{an_email.subject} and the body #{an_email.body}"
  end
end
