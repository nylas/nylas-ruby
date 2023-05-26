# frozen_string_literal: true

require_relative "base_resource"
require_relative "../operations/api_operations"
# require other mixins as needed

module Nylas
  class Events < BaseResource
    include Operations::Create
    include Operations::Find
    include Operations::List
    include Operations::Update
    include Operations::Destroy
    # include other mixins as needed

    def initialize(sdk_instance)
      super("events", sdk_instance)
    end
  end
end
