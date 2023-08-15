# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/admin_api_operations"

module Nylas
  # Redirect URIs
  class RedirectUris < Resource
    include AdminApiOperations::Create
    include AdminApiOperations::Update
    include AdminApiOperations::List
    include AdminApiOperations::Destroy
    include AdminApiOperations::Find

    # Initializes redirect URIs.
    def initialize(sdk_instance)
      super("applications/redirect-uris", sdk_instance)
    end
  end
end
