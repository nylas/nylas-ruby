# frozen_string_literal: true

module Nylas
  Error = Class.new(::StandardError)

  class JsonParseError < Error; end

  # Base class to inflate the standard errors returned from the Nylas API.
  class NylasApiError < Error
    attr_accessor :type, :request_id, :provider_error, :status_code

    def initialize(type, message, status_code, provider_error = nil, request_id = nil)
      super(message)
      self.type = type
      self.status_code = status_code
      self.provider_error = provider_error
      self.request_id = request_id
    end

    def self.parse_error_response(response, status_code)
      new(
        response["type"],
        response["message"],
        status_code,
        response["provider_error"]
      )
    end
  end

  class NylasOAuthError < Error
    attr_accessor :error, :error_description, :error_uri, :error_code, :status_code

    def initialize(error, error_description, error_uri, error_code, status_code)
      super(error_description)
      self.error = error
      self.error_description = error_description
      self.error_uri = error_uri
      self.error_code = error_code
      self.status_code = status_code
    end
  end

  HTTP_SUCCESS_CODES = [200, 201, 202, 302].freeze
end
