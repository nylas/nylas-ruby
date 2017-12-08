# A basic sinatra app that goes through the auth flow to make
# sure there's no breakage.

require 'sinatra/base'
require 'nylas'

$:.unshift File.join(File.dirname(__FILE__))

begin
  load 'credentials.rb'
rescue LoadError
  puts "It seems you didn't create a 'credentials.rb' file. Look at credentials.rb.template for an example."
  exit
end

print APP_ID

ENDPOINTS = [
  {:api_path => "https://api.nylas.com", :login_domain => "api.nylas.com"},
]

class App < Sinatra::Base
  get '/' do

    entry = params[:entry].to_i
    api_path = ENDPOINTS[entry][:api_path]
    login_domain = ENDPOINTS[entry][:login_domain]

    inbox = Nylas::API.new(app_id: APP_ID, app_secret: APP_SECRET, access_token: nil, api_server: api_path,
                           service_domain: login_domain)

    # This URL must be registered with your application in the developer portal
    callback_url = "http://localhost:4567/callback"
    redirect to(inbox.url_for_authentication(callback_url, nil, :state => 'blue_state'))
  end

  get '/callback' do
    api_path = ENDPOINTS[0][:api_path]
    login_domain = ENDPOINTS[0][:login_domain]

    inbox = Nylas::API.new(app_id: APP_ID, app_secret: APP_SECRET, access_token: nil, api_server: api_path,
                           service_domain: login_domain)
    inbox_token = inbox.token_for_code(params[:code])
    inbox = Nylas::API.new(app_id: APP_ID, app_secret: APP_SECRET, access_token: inbox_token,
                           api_server: api_path, service_domain:login_domain)
    return inbox_token
  end

  set :logging, nil
  run! do
    puts <<-eos

      _   _       _
     | \ | |     | |
     |  \| |_   _| | __ _ ___
     | . ` | | | | |/ _` / __|
     | |\  | |_| | | (_| \__ \\
     \_| \_/\__, |_|\__,_|___/
             __/ |
            |___/
\033[0m\033[94m
      A P I  S E L F - T E S T\033[0m

\n\n
Hey! Welcome to the Ruby SDK auth test program. I need your help to make sure we didn't break authing to the API.

Could you go to the following URL and make sure you're getting an access token?
    eos

    puts "\033[0m\033[94m"
    ENDPOINTS.length.times do |i|
      puts "#{ENDPOINTS[i][:login_domain]} ==> http://localhost:4567/?entry=#{i}"
    end
    puts "\033[0m"
  end
end
