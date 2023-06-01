# frozen_string_literal: true

module Nylas
  # BaseResource is the base class for all Nylas API resources.
  class BaseResource
    def initialize(resource_name, sdk_instance)
      @resource_name = resource_name
      @api_key = sdk_instance.api_key
      @host = sdk_instance.host
      @timeout = sdk_instance.timeout
    end

    private

    attr_reader :resource_name, :api_key, :host, :timeout
  end
end
