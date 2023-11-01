# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/grants_api_operations"

module Nylas
  # Calendars
  class Messages < Resource
    include GrantsApiOperations::Update
    include GrantsApiOperations::List
    include GrantsApiOperations::Destroy
    include GrantsApiOperations::Find

    # Initializes Calendars.
    def initialize(sdk_instance)
      super("messages", sdk_instance)
    end
  end
end
