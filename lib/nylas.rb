require 'json'
require 'rest-client'

require 'ostruct'
require 'forwardable'

require 'nylas/version'

require_relative 'nylas/logging'
require_relative 'nylas/registry'
require_relative 'nylas/to_query'
require_relative 'nylas/types_filter'
require_relative 'nylas/types'
require_relative 'nylas/constraints'

require_relative 'nylas/collection'
require_relative 'nylas/model'



require_relative 'nylas/email_address'
require_relative 'nylas/im_address'
require_relative 'nylas/physical_address'
require_relative 'nylas/phone_number'
require_relative 'nylas/web_page'
require_relative 'nylas/nylas_date'




require 'nylas/v2'

require_relative 'nylas/api'

module Nylas
  Error = Class.new(::StandardError)
  NoAuthToken = Class.new(Error)
  UnexpectedAccountAction = Class.new(Error)
  UnexpectedResponse = Class.new(Error)
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

  HTTP_CODE_TO_EXCEPTIONS = {
    400 => InvalidRequest,
    402 => MessageRejected,
    403 => AccessDenied,
    404 => ResourceNotFound,
    422 => MailProviderError,
    429 => SendingQuotaExceeded,
    500 => InternalError,
    502 => BadGateway,
    503 => ServiceUnavailable,
  }.freeze
end
