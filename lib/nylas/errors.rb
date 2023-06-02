# frozen_string_literal: true

module Nylas
  Error = Class.new(::StandardError)

  class JsonParseError < Error; end

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

  UnexpectedAccountAction = Class.new(Error)
  UnexpectedResponse = Class.new(Error)
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

  HTTP_SUCCESS_CODES = [200, 201, 202, 302].freeze

  HTTP_CODE_TO_EXCEPTIONS = {
    400 => InvalidRequest,
    401 => UnauthorizedRequest,
    402 => MessageRejected,
    403 => AccessDenied,
    404 => ResourceNotFound,
    405 => MethodNotAllowed,
    410 => ResourceRemoved,
    418 => TeapotError,
    422 => MailProviderError,
    429 => SendingQuotaExceeded,
    500 => InternalError,
    501 => EndpointNotYetImplemented,
    502 => BadGateway,
    503 => ServiceUnavailable,
    504 => RequestTimedOut
  }.freeze
end
