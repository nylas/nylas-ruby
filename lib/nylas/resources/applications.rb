# frozen_string_literal: true

require_relative "resource"
require_relative "redirect_uris"
require_relative "../handler/api_operations"

module Nylas
  # Application
  class Applications < Resource
    include ApiOperations::Get
    include ApiOperations::Patch

    attr_reader :redirect_uris

    # Initializes the application.
    def initialize(sdk_instance)
      super(sdk_instance)
      @redirect_uris = RedirectUris.new(sdk_instance)
    end

    # Get application details.
    #
    # @return [Array(Hash, String)] Application details and API Request ID.
    def get_details
      get(path: "#{api_uri}/v3/applications")
    end

    # Update application details.
    #
    # @param request_body [Hash] The values to update the application with.
    # @return [Array(Hash, String)] The updated application details and API Request ID.
    def update(request_body:)
      patch(
        path: "#{api_uri}/v3/applications",
        request_body: request_body
      )
    end
  end
end
