# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"
# require other mixins as needed

module Nylas
  # Events
  class Events < Resource
    include Operations::Create
    include Operations::Update
    include Operations::List
    include Operations::Destroy
    include Operations::Find

    def initialize(sdk_instance)
      super("events", sdk_instance)
    end
  end
end
