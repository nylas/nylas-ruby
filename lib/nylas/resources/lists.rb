# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Module representing the possible 'type' values for a List.
  module ListType
    DOMAIN = "domain"
    TLD = "tld"
    ADDRESS = "address"
  end

  # Nylas Lists API
  #
  # Lists are typed collections of domains, TLDs, or email addresses that can
  # be referenced by Rules using the +in_list+ condition operator.
  class Lists < Resource
    include ApiOperations::Post

    # Create a list for the application.
    #
    # @param request_body [Hash] The public values to create the list with.
    #   Supported keys: +name+ (required, 1-256 chars), +type+ (required; one of
    #   +domain+, +tld+, or +address+), and +description+ (optional). The server
    #   assigns identifiers, item counts, timestamps, and application ownership.
    # @return [Array(Hash, String, Hash)] The created list, API Request ID, and
    #   response headers.
    def create(request_body:)
      post(
        path: "#{api_uri}/v3/lists",
        request_body: request_body
      )
    end
  end
end
