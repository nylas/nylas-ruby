require 'yaml'
require 'nylas'
require 'sinatra'

# Enable session to store token
enable :sessions
set :session_secret, 'my_super_secret_code'


# Load secrets from config file
config = YAML.load_file('config.yml')

# This URL must be registered with your application in the developer portal
CALLBACK_URL = config["nylas_callback_url"]
APP_ID = config["nylas_app_id"]
APP_SECRET = config["nylas_app_secret"]


# Check app configuration before starting 
if APP_ID == 'YOUR_APP_ID' or APP_SECRET == 'YOUR_APP_SECRET'
    raise "You need to configure your app id and secrets in config.yml"
end



def login
    nylas = Nylas::API.new(APP_ID, APP_SECRET, nil)
    nylas.url_for_authentication(CALLBACK_URL, nil)
end


def get_token
    nylas = Nylas::API.new(APP_ID, APP_SECRET, nil)
    nylas.token_for_code(params[:code])
end



get '/' do
    # Redirect to login if session doesn't have an access token
    redirect to(login) unless session[:nylas_token]

    nylas = Nylas::API.new(APP_ID, APP_SECRET, session[:nylas_token])

    # Get the first five threads for the account.
    recent_emails = []
    nylas.threads.where(:tag => 'unread').range(0,5).each do |thread|
      recent_emails.push(thread.subject)
    end

    # List messages on the first thread
    body = "Hello #{nylas.account.name}, here are your last 5 emails:\n<br><br>"
    body += "#{recent_emails.join('<br>')}"

    body
end


get '/login_callback' do
    # get token from code
    nylas_token = get_token

    if nylas_token
        # Store token in a session
        session[:nylas_token] = nylas_token
        redirect to('/')
    end

    "Error during auth"
end
