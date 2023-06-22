# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/grants_api_operations"

module Nylas
  # redirect uris
  class RedirectUris < Resource
    include GrantsApiOperations::Create
    include GrantsApiOperations::Update
    include GrantsApiOperations::List
    include GrantsApiOperations::Destroy
    include GrantsApiOperations::Find

    def initialize(sdk_instance)
      super("redirect-uris", sdk_instance)
    end
  end
end
