require 'json'
require 'rest-client'

require 'ostruct'

# Shared libraries between V1 and V2 of the API
require_relative 'nylas/errors'
require_relative 'nylas/http_client'
require_relative 'nylas/hash_to_query'
require_relative 'nylas/version'


# V1 API Access, deprecated; kept around so people can migrate to V2 gradually
require_relative 'nylas/v1'
require_relative 'nylas/api'

# V2 API Access, Provides ActiveModel/ActiveResource compatible interface
require_relative 'nylas/v2'

module Nylas
  # @param version [String] Which version of the API your application uses. May be "1" or "2".
  # @param app_id [String] The application's OAuth Client ID. Can be found on
  #                        {https://dashboard.nylas.com/applications/ your applications Nylas API Dashboard}
  # @param app_secret [String] The applications OAuth Client Secret. Can be found on
  #                            {https://dashboard.nylas.com/applications/ your applications Nylas API
  #                            Dashboard}
  # @return [Nylas::V1::SDK, Nylas::V2::SDK]
  def self.sdk(version: , app_id: , app_secret: ,access_token: nil, service_domain: 'api.nylas.com', api_server: 'https://api.nylas.com')
    client = HttpClient.new(app_id: app_id, app_secret: app_secret, access_token: access_token,
                            service_domain: service_domain, api_server: api_server)
    if version == 2
      V2::SDK.new(client: client)
    elsif version == 1
      require_relative 'v1'
      V1::SDK.new(client: client)
    end
  end
end
