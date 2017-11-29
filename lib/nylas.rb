require 'json'
require 'rest-client'

require 'ostruct'
require_relative 'nylas/to_query'

require_relative 'nylas/types_filter'

require 'nylas/account'
require 'nylas/api_account'
require 'nylas/thread'
require 'nylas/calendar'
require 'nylas/account'
require 'nylas/message'
require 'nylas/expanded_message'
require 'nylas/draft'
require 'nylas/contact'
require 'nylas/file'
require 'nylas/calendar'
require 'nylas/event'
require 'nylas/folder'
require 'nylas/label'
require 'nylas/restful_model'
require 'nylas/restful_model_collection'
require 'nylas/version'

require 'nylas/v2'

require_relative 'nylas/api'

module Nylas
  OBJECTS_TABLE = {
    "account" => Nylas::Account,
    "calendar" => Nylas::Calendar,
    "draft" => Nylas::Draft,
    "thread" => Nylas::Thread,
    "contact" => Nylas::Contact,
    "event" => Nylas::Event,
    "file" => Nylas::File,
    "message" => Nylas::Message,
    "folder" => Nylas::Folder,
    "label" => Nylas::Label,
  }

  # It's possible to ask the API to expand objects.
  # In this case, we do the right thing and return
  # an expanded object.
  EXPANDED_OBJECTS_TABLE = {
    "message" => Nylas::ExpandedMessage,
  }
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

  def self.http_code_to_exception(http_code)
    API.http_code_to_exception(http_code)
  end

  def self.interpret_response(result, result_content, options = {})
    return API.interpret_response(result, result_content, options)
  end
end
