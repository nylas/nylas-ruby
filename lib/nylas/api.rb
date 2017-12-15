module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects
  class API
    attr_accessor :client
    extend Forwardable
    def_delegators :client, :execute, :get, :post, :put, :delete, :app_id

    include Logging

    # @param client [HttpClient] Http Client to use for retrieving data
    # @param app_id [String] Your application id from the Nylas Dashboard
    # @param app_secret [String] Your application secret from the Nylas Dashboard
    # @param access_token [String] (Optional) Your users access token.
    # @param api_server [String] (Optional) Which Nylas API Server to connect to. Only change this if
    #                            you're using a self-hosted Nylas instance.
    # @param service_domain [String] (Optional) Host you are authenticating OAuth against.
    # @return [Nylas::API]
    # rubocop:disable Metrics/ParameterLists
    def initialize(client: nil, app_id: nil, app_secret: nil, access_token: nil,
                   api_server: "https://api.nylas.com", service_domain: "api.nylas.com")
      self.client = client || HttpClient.new(app_id: app_id, app_secret: app_secret,
                                             access_token: access_token, api_server: api_server,
                                             service_domain: service_domain)
    end
    # rubocop:enable Metrics/ParameterLists

    # @return [Collection<Contact>] A queryable collection of Contacts
    def contacts
      @contacts ||= Collection.new(model: Contact, api: self)
    end

    # @return [CurrentAccount] The account details for whomevers access token is set
    def current_account
      prevent_calling_if_missing_access_token(:current_account)
      CurrentAccount.from_hash(execute(method: :get, path: "/account"), api: self)
    end

    # @return [Collection<Account>] A queryable collection of Accounts
    def accounts
      @accounts ||= Collection.new(model: Account, api: as(client.app_secret))
    end

    # Allows you to get an API that acts as a different user but otherwise has the same settings
    # @param [String] Oauth Access token or app secret used to authenticate with the API
    # @return [API]
    def as(access_token)
      API.new(client: client.as(access_token))
    end

    # @return [Collection<Thread>] A queryable collection of Threads
    def threads
      @threads ||= Collection.new(model: Thread, api: self)
    end

    private def prevent_calling_if_missing_access_token(method_name)
      return if client.access_token && !client.access_token.empty?
      raise NoAuthToken, method_name
    end
  end
end
