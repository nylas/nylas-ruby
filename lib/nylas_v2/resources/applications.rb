# frozen_string_literal: true

require_relative "resource"
require_relative "redirect_uris"
require_relative "../handler/api_operations"

module NylasV2
  # Application
  class Applications < Resource
    include ApiOperations::Get

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
  end
end
