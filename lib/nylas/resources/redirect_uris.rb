# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"
# require other mixins as needed

module Nylas
  # redirect uris
  class RedirectURIs < BaseResource
    include Operations::Create
    include Operations::Update
    include Operations::List
    include Operations::Destroy
    include Operations::Find

    def initialize(sdk_instance)
      super("redirect-uris", sdk_instance)
    end
  end
end
