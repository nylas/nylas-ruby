require 'sinatra'
require 'yaml'
require 'json'
require 'open-uri'

set :port, 1234

# Load secrets from config file
config = YAML.load_file('config.yml')
NYLAS_CLIENT_SECRET = config["NYLAS_CLIENT_SECRET"]

# Check app configuration before starting
if NYLAS_CLIENT_SECRET == ''
    raise "You need to configure your Nylas client secret in config.yml"
end


# Nylas will check to make sure your webhook is valid by making a GET
# request to your endpoint with a challenge parameter when you add the
# endpoint to the developer dashboard.  All you have to do is return the
# value of the challenge parameter in the body of the response.
get '/webhook' do
  status 200
  params['challenge']
end 

# Nylas sent us a webhook notification for some kind of event, so we should
# process it!
post '/webhook' do
  # Verify the request to make sure it's actually from Nylas.
  request.body.rewind
  data = request.body.read
  if not verify_request(data, request.env['HTTP_X_NYLAS_SIGNATURE'])
    puts 'failed'
    return 401
  end

  # Nylas will send us a json object of the deltas.
  data = JSON.parse(data.to_s)
  # Print some of the information Nylas sent us. This is where you
  # would normally process the webhook notification and do things like
  # fetch relevant message ids, update your database, etc.
  data['deltas'].each do | delta |
    puts "#{delta['type']} at #{delta['date']} with id #{delta['object_data']['id']}"
  end

  # Don't forget to let the Nylas API know that everything was pretty ok.
  status 200
end 

# Each request made by Nylas includes an X-Nylas-Signature header. The header
# contains the HMAC-SHA256 signature of the request body, using your client
# secret as the signing key. This allows your app to verify that the
# notification really came from Nylas.
def verify_request(data, signature)
  digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), NYLAS_CLIENT_SECRET, data)
  return Rack::Utils.secure_compare(digest, signature)
end

## Setup ngrok settings to ensure everything works locally 
def init_ngrok()
  # Make sure ngrok is running
  begin
    response = JSON.parse(open('http://localhost:4040/api/tunnels').read)
    ngrok = response['tunnels'][1]['public_url']
  rescue Errno::ECONNREFUSED
    abort "It looks like ngrok isn't running! Make sure you've started that first with 'ngrok http 1234'"
  end
  puts "#{ngrok}/webhook\nAdd the above url to the webhooks page at https://developer.nylas.com\n"
end

init_ngrok()
