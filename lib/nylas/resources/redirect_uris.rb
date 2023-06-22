# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/admin_api_operations"

module Nylas
  # redirect uris
  class RedirectUris < Resource
    include AdminApiOperations::Create
    include AdminApiOperations::Update
    include AdminApiOperations::List
    include AdminApiOperations::Destroy
    include AdminApiOperations::Find

    def initialize(sdk_instance)
      super("redirect-uris", sdk_instance)
    end
  end
end
