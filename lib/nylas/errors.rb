module Nylas
  Error = Class.new(::StandardError)

  # Indicates that a given method needs an access token to work.
  class NoAuthToken < Error
    def initialize(method_name)
      super "No access token was provided and the #{method_name} method requires one"
    end
  end

  UnexpectedAccountAction = Class.new(Error)
  UnexpectedResponse = Class.new(Error)

  # Base class to inflate the standard errors returned from the Nylas API
  class APIError < Error
    attr_accessor :type
    attr_accessor :message
    attr_accessor :server_error

    def initialize(type, message, server_error = nil)
      super(message)
      self.type = type
      self.message = message
      self.server_error = server_error
    end
  end
  AccessDenied = Class.new(APIError)
  ResourceNotFound = Class.new(APIError)
  InvalidRequest = Class.new(APIError)
  MessageRejected = Class.new(APIError)
  SendingQuotaExceeded = Class.new(APIError)
  ServiceUnavailable = Class.new(APIError)
  BadGateway = Class.new(APIError)
  InternalError = Class.new(APIError)
  MailProviderError = Class.new(APIError)
end
