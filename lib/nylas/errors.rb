# frozen_string_literal: true

module Nylas
  Error = Class.new(::StandardError)

  class JsonParseError < Error; end

  # Base class to inflate the standard errors returned from the Nylas API.
  class NylasApiError < Error
    attr_accessor :type, :request_id, :provider_error, :status_code

    # Initializes an error and assigns the given attributes to it.
    #
    # @param type []
    # @param message [String] The error message.
    # @param status_code [Hash] The associated status code.
    # @param provider_error [String, nil] The provider error, if applicable. Defaults to `nil`.
    # @param request_id [Hash, nil] The ID of the request. Defaults to `nil`.
    def initialize(type, message, status_code, provider_error = nil, request_id = nil)
      super(message)
      self.type = type
      self.status_code = status_code
      self.provider_error = provider_error
      self.request_id = request_id
    end

    # Parses the error response.
    #
    # @param response [Hash] The response from the Nylas API.
    # @param status_code [String] The error status code.
    def self.parse_error_response(response, status_code)
      new(
        response["type"],
        response["message"],
        status_code,
        response["provider_error"]
      )
    end
  end

  # Base class to inflate the standard errors returned from the Nylas OAuth integration.
  class NylasOAuthError < Error
    attr_accessor :error, :error_description, :error_uri, :error_code, :status_code

    # Initializes an error and assigns the given attributes to it.
    #
    # @param error []
    # @param error_description [String] The description of the error.
    # @param error_uri [Hash] The URI of the error.
    # @param error_code [Hash] The error code.
    # @param status_code [Hash] The associated status code.
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
