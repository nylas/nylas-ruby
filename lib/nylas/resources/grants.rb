# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Grants
  class Grants < Resource
    include Operations::Create
    include Operations::Update
    include Operations::List
    include Operations::Destroy
    include Operations::Find

    def initialize(sdk_instance)
      super("grants", sdk_instance)
    end
  end
end
