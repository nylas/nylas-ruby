# frozen_string_literal: true

module Nylas
  Error = Class.new(::StandardError)

  class JsonParseError < Error; end

  # Base class to inflate the standard errors returned from the Nylas API.
  class NylasApiError < Error
    attr_accessor :type, :request_id, :provider_error, :status_code

    # Initializes an error and assigns the given attributes to it.
    #
    # @param type [Hash] Error type.
    # @param message [String] Error message.
    # @param status_code [Hash] Error status code.
    # @param provider_error [String, nil] Provider error.
    # @param request_id [Hash, nil] The ID of the request.
    def initialize(type, message, status_code, provider_error = nil, request_id = nil)
      super(message)
      self.type = type
      self.status_code = status_code
      self.provider_error = provider_error
      self.request_id = request_id
    end

    # Parses the error response.
    #
    # @param response [Hash] Response from the Nylas API.
    # @param status_code [String] Error status code.
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
    # @param error [Hash] Error type.
    # @param error_description [String] Description of the error.
    # @param error_uri [Hash] Error URI.
    # @param error_code [Hash] Error code.
    # @param status_code [Hash] Error status code.
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
