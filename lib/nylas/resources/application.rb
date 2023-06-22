# frozen_string_literal: true

require_relative "resource"
require_relative "redirect_uris"

module Nylas
  # Application
  class Application < Resource
    attr_reader :redirect_uris

    def initialize(sdk_instance)
      super("application", sdk_instance)
      @redirect_uris = RedirectUris.new(sdk_instance)
    end

    # Gets the application object
    # @return [Array(Hash, String)] The Application object and API Request ID
    def info
      get("#{host}/applications")
    end
  end
end
