module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects
  class API
    attr_accessor :client
    extend Forwardable
    def_delegators :client, :execute, :get, :post, :put, :delete

    include Logging

    # @param client [HttpClient] Http Client to use for retrieving data
    # @param app_id [String] Your application id from the Nylas Dashboard
    # @param app_secret [String] Your application secret from the Nylas Dashboard
    # @param access_token [String] (Optional) Your users access token.
    # @param api_server [String] (Optional) Which Nylas API Server to connect to. Only change this if
    #                            you're using a self-hosted Nylas instance.
    # @param service_domain [String] (Optional) Host you are authenticating OAuth against.
    # @return [Nylas::API]
    def initialize(client: nil, app_id: nil, app_secret: nil, access_token: nil,
                   api_server: 'https://api.nylas.com', service_domain: 'api.nylas.com')
      self.client = client || HttpClient.new(app_id: app_id, app_secret: app_secret,
                                             access_token: access_token, api_server: api_server,
                                             service_domain: service_domain)
    end

    # @return [Collection<Contact>] A queryable collection of Contacts
    def contacts
      @contacts ||= Collection.new(model: Contact, api:self)
    end

    # @return [CurrentAccount] The account details for whomevers access token is set
    def current_account

    end

  end
end
