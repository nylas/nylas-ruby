# frozen_string_literal: true

module Nylas
  # BaseResource is the base class for all Nylas API resources.
  class BaseResource
    attr_reader :resource_name, :sdk_instance

    def initialize(resource_name, sdk_instance)
      @resource_name = resource_name
      @sdk_instance = sdk_instance
    end

    private

    def api_key
      sdk_instance.api_key
    end

    def host
      sdk_instance.host
    end
  end
end
