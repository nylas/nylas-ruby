# frozen_string_literal: true

require_relative "resource"
require_relative "redirect_uris"
require_relative "../handler/api_operations"

module Nylas
  # Application
  class Applications < Resource
    include ApiOperations::Get

    attr_reader :redirect_uris

    def initialize(sdk_instance)
      super("applications", sdk_instance)
      @redirect_uris = RedirectUris.new(sdk_instance)
    end

    # Gets the application object
    # @return [Array(Hash, String)] The Application object and API Request ID
    def info
      get(path: "#{host}/v3/applications")
    end
  end
end
