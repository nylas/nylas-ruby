# frozen_string_literal: true

module Nylas
  # NOTE: BaseResource is the base class for all Nylas API resources.
  # Used by all Nylas API resources
  class Resource
    # Initializes a resource.
    def initialize(resource_name, sdk_instance)
      @resource_name = resource_name
      @api_key = sdk_instance.api_key
      @api_uri = sdk_instance.api_uri
      @timeout = sdk_instance.timeout
    end

    private

    attr_reader :resource_name, :api_key, :api_uri, :timeout
  end
end
