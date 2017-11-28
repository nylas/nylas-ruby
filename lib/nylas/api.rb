require_relative 'v1/sdk'
module Nylas
  # Shim to maintain backwards compatibility
  class API < V1::SDK
    def initialize(app_id, app_secret, access_token = nil, api_server = 'https://api.nylas.com',
                   service_domain = 'api.nylas.com')
      raise "When overriding the Nylas API server address, you must include https://" unless api_server.include?('://')
      client = HttpClient.new(app_id: app_id,
                              app_secret: app_secret,
                              access_token: access_token,
                              service_domain: service_domain,
                              api_server: api_server)
      super(client: client)
    end
  end
end
