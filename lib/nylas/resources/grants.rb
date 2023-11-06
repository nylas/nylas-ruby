# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/admin_api_operations"

module Nylas
  # Grants
  class Grants < Resource
    include ApiOperations::Post
    include AdminApiOperations::Update
    include AdminApiOperations::List
    include AdminApiOperations::Destroy
    include AdminApiOperations::Find

    # Initializes Grants.
    def initialize(sdk_instance)
      super("grants", sdk_instance)
    end

    # Create a Grant via Custom Authentication.
    #
    # @param request_body [Hash] The values to create the Grant with.
    # @return [Array(Hash, String)] Created grant and API Request ID.
    def create(request_body)
      post(
        path: "#{api_uri}/v3/#{resource_name}/custom",
        request_body: request_body
      )
    end
  end
end
