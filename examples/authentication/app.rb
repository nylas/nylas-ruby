require 'active_support/core_ext/hash'
require 'sinatra'
require 'yaml'
require 'json'
require 'open-uri'
require 'nylas'
require 'rest-client'
  
set :port, 1234
enable :sessions # Allows sinatra to persist session information for a user

# Load secrets from config file
config = YAML.load_file('config.yml')
NYLAS_CLIENT_SECRET  = config["NYLAS_CLIENT_SECRET"]
GOOGLE_CLIENT_ID     = config["GOOGLE_CLIENT_ID"]
GOOGLE_CLIENT_SECRET = config["GOOGLE_CLIENT_SECRET"]
NYLAS_CLIENT_ID      = config["NYLAS_CLIENT_ID"]

# Check app configuration before starting
if NYLAS_CLIENT_SECRET == ''
    raise "You need to configure your client keys in config.yml"
end

# These are the permissions your app will ask the user to approve for access
# https://developers.google.com/identity/protocols/OAuth2WebServer#scope
GOOGLE_SCOPES = ['https://mail.google.com/',
                  'https://www.googleapis.com/auth/calendar',
                  'https://www.googleapis.com/auth/userinfo.email',
                  'https://www.googleapis.com/auth/userinfo.profile',
                  'https://www.googleapis.com/auth/calendar',
                  'https://www.google.com/m8/feeds/'] * ' '

# This is the path in your Google application that users are redirected to after
# they have authenticated with Google, and it must be authorized through
# Google's developer console
$redirect_uri = "http://localhost:#{settings.port}/google/oauth2callback"
NYLAS_API = 'https://api.nylas.com'
GOOGLE_OAUTH_TOKEN_VALIDATION_URL = 'https://www.googleapis.com/oauth2/v2/tokeninfo'
GOOGLE_OAUTH_AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
GOOGLE_OAUTH_ACCESS_TOKEN_URL = 'https://www.googleapis.com/oauth2/v4/token'

# This is the url Google will call once a user has approved access to their
# account
get '/google/oauth2callback' do
  if not params['code']
    data = {
                :response_type => 'code',
                :access_type   => 'offline',
                :client_id     => GOOGLE_CLIENT_ID,
                :redirect_uri  => $redirect_uri,
                :scope         => GOOGLE_SCOPES,
                # Note: this is only for testing to ensure a refresh token is
                # passed everytime, but requires the user to approve offline
                # access every time. You should remove this if you don't want
                # your user to have to approve access each time they connect
                :prompt => 'consent',
             }

    # Redirect the user to Google so that they can authenticate. They'll be
    # redirected back here again afterwards
    auth_uri = GOOGLE_OAUTH_AUTH_URL + '?' + data.to_query
    redirect to(auth_uri)
  else
    # The user just successfully authenticated with Google and was redirected
    # back here with a Google code
    auth_code = params['code']
    data = {
              :code          => auth_code,
              :client_id     => GOOGLE_CLIENT_ID,
              :client_secret => GOOGLE_CLIENT_SECRET,
              :redirect_uri  => $redirect_uri,
              :grant_type    => 'authorization_code'
           }
     
    # Using Google's authorization code we can get an access and refresh token
    r = RestClient.post GOOGLE_OAUTH_ACCESS_TOKEN_URL, data
    # This refresh token will only be returned once unless you prompt the user
    # for consent every time, so be sure to remember it!
    data = JSON.parse(r.body)
    session[:google_refresh_token] = data['refresh_token']
    session[:google_access_token] = data['access_token']
    redirect to('/google')
  end
end

get '/google' do
  # User hasn't authorized with google yet, so we should redirect
  if not session[:google_access_token]
    redirect to('/google/oauth2callback')
  end

  # The user has authorized with google at this point but we will need to
  # connect the account to Nylas
  if not session[:nylas_access_token]
      google_access_token = session[:google_access_token]
      email_address = get_email_from_access_token(google_access_token)
      google_refresh_token = session[:google_refresh_token]
      google_settings = {
                          :google_client_id     => GOOGLE_CLIENT_ID,
                          :google_client_secret => GOOGLE_CLIENT_SECRET,
                          :google_refresh_token => google_refresh_token
                        }
      data = {
               :client_id     => NYLAS_CLIENT_ID,
               :name          => 'Your Name',
               :email_address => email_address,
               :provider      => 'gmail',
               :settings      => google_settings
             }
      connect_to_nylas(data)
  end

  # User has succesfully authorized with google and connected to Nylas. Redirect
  # to homepage so we can show some emails!
  redirect to('/')
end

post '/exchange' do
  # User gave us their username and password and submitted the form. Use the
  # data now to login with Nylas
  if not session[:nylas_access_token]
    exchange_settings = {
                         :username => params['email'],
                         :password => params['password'],
                        }
    data = {
             :client_id     => NYLAS_CLIENT_ID,
             :name          => params['name'],
             :email_address => params['email'],
             :provider      => 'exchange',
             :settings      => exchange_settings 
           }
    connect_to_nylas(data)
  end
  # User has succesfully connected to Nylas with their exchange address.
  # Redirect to homepage so we can show some emails!
  redirect to('/')
end

get '/exchange' do
  # Show a login form for a user to enter their information
  send_file 'views/exchange_login.html'
end

get '/choose-login' do
  # Let the user choose what email they want to login with
  send_file 'views/choose_login.html'
end

get '/logout' do
  session.clear
  redirect to('/')
end

get  '/' do
  if not session[:nylas_access_token]
    # If the user hasn't connected their email account from any provider, send
    # them to a login page that will allow them to connect any kind of account
    redirect to('/choose-login')
  end

  # Account has been setup, let's use Nylas' ruby SDK to retrieve an email
  nylas = Nylas::API.new(NYLAS_CLIENT_ID, NYLAS_CLIENT_SECRET, session[:nylas_access_token])

  # Get the first thread for the account.
  recent_emails = []
  nylas.messages.range(0,1).each do |message|
    recent_emails.push(message.body)
  end

  # List messages on the first thread
  body = "<a href='/logout'>logout</a>"
  body += "#{recent_emails.join('<br>')}"
  body
end

# Uses googles tokeninfo endpoint to get an email address from the google
# access_token
def get_email_from_access_token(google_access_token)
  data= {
           :access_token => google_access_token,
           :fields       => 'email' # specify we only want the email
        } 
  r = RestClient.post GOOGLE_OAUTH_TOKEN_VALIDATION_URL, data
  json = JSON.parse(r.body)
  puts "\n#{json['email']}\n"
  json['email']
end

# First POST to /connect/authorize to get an authorization code from Nylas
# Then post to /connect/token to get an access_token that can be used to access
# account data
def connect_to_nylas(data)
    code = nylas_code(data)
    data = {
             :client_id     => NYLAS_CLIENT_ID,
             :client_secret => NYLAS_CLIENT_SECRET,
             :code          => code
            }
    nylas_access_token = nylas_token(data)
    session[:nylas_access_token] = nylas_access_token
end

def nylas_code(data)
  connect_uri = NYLAS_API + '/connect/authorize'
  r = RestClient.post connect_uri, data.to_json, :content_type => :json, :accept => :json
  json = JSON.parse(r.body)
  return json['code']
end

def nylas_token(data)
  token_uri = NYLAS_API + '/connect/token'
  r = RestClient.post token_uri, data.to_json, :content_type => :json, :accept => :json
  json = JSON.parse(r.body)
  return json['access_token']
end

puts $redirect_uri
puts "Have you added the url above as an authorized callback in Google's developer console (y/n)? "
s = gets.chomp
if s != 'y'
  puts "You need to set that up first!"
  abort "See https://support.nylas.com/hc/en-us/articles/222176307-Google-OAuth-Setup-Guide for more information"
end
