# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"
require_relative "redirect_uris"
# require other mixins as needed

module Nylas
  # Application
  class Application < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    attr_reader :redirect_uris

    def initialize(sdk_instance)
      super("application", sdk_instance)
      @redirect_uris = RedirectURIs.new(sdk_instance)
    end

    def info
      get("#{host}/applications")
    end
  end
end
