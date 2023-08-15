# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/admin_api_operations"

module Nylas
  # Grants
  class Grants < Resource
    include AdminApiOperations::Create
    include AdminApiOperations::Update
    include AdminApiOperations::List
    include AdminApiOperations::Destroy
    include AdminApiOperations::Find

    # Initializes Grants.
    def initialize(sdk_instance)
      super("grants", sdk_instance)
    end
  end
end
