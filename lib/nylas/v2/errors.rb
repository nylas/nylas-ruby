# frozen_string_literal: true

module Nylas::V2
  Error = Class.new(::StandardError)

  class ModelActionError < Error; end
  class ModelNotFilterableError < ModelActionError; end
  class ModelNotCreatableError < ModelActionError; end
  class ModelNotShowableError < ModelActionError; end
  class ModelNotAvailableAsRawError < ModelActionError; end
  class ModelNotListableError < ModelActionError; end
  class ModelNotFilterableError < ModelActionError; end
  class ModelNotSearchableError < ModelActionError; end
  class ModelNotUpdatableError < ModelActionError; end
  class ModelNotDestroyableError < ModelActionError; end

  class JsonParseError < Error; end

  # Raised when attempting to set a field that is not on a model with mass assignment
  class ModelMissingFieldError < ModelActionError
    def initialize(field, model)
      super("#{field} is not a valid attribute for #{model.class.name}")
    end
  end

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

    def self.parse_error_response(response)
      new(
        response["type"],
        response["message"],
        response["server_error"]
      )
    end
  end

  # Error class representing a 429 error response, with details on the rate limit
  class RateLimitError < APIError
    attr_accessor :rate_limit
    attr_accessor :rate_limit_reset

    RATE_LIMIT_LIMIT_HEADER = "x_ratelimit_limit"
    RATE_LIMIT_RESET_HEADER = "x_ratelimit_reset"

    def initialize(type, message, server_error = nil, rate_limit = nil, rate_limit_reset = nil)
      super(type, message, server_error)
      self.rate_limit = rate_limit
      self.rate_limit_reset = rate_limit_reset
    end

    def self.parse_error_response(response)
      rate_limit, rate_limit_rest = extract_rate_limit_details(response)

      new(
        response["type"],
        response["message"],
        response["server_error"],
        rate_limit,
        rate_limit_rest
      )
    end

    def self.extract_rate_limit_details(response)
      return nil, nil unless response.respond_to?(:headers)

      rate_limit = response.headers[RATE_LIMIT_LIMIT_HEADER.to_sym].to_i
      rate_limit_rest = response.headers[RATE_LIMIT_RESET_HEADER.to_sym].to_i

      [rate_limit, rate_limit_rest]
    end

    private_class_method :extract_rate_limit_details
  end

  AccessDenied = Class.new(APIError)
  ResourceNotFound = Class.new(APIError)
  MethodNotAllowed = Class.new(APIError)
  InvalidRequest = Class.new(APIError)
  UnauthorizedRequest = Class.new(APIError)
  ResourceRemoved = Class.new(APIError)
  TeapotError = Class.new(APIError)
  RequestTimedOut = Class.new(APIError)
  MessageRejected = Class.new(APIError)
  SendingQuotaExceeded = Class.new(RateLimitError)
  ServiceUnavailable = Class.new(APIError)
  BadGateway = Class.new(APIError)
  InternalError = Class.new(APIError)
  EndpointNotYetImplemented = Class.new(APIError)
  MailProviderError = Class.new(APIError)
end
