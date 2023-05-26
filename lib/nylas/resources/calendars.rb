# frozen_string_literal: true

require_relative "base_resource"
require_relative "operations/api_operations"

module Nylas
  class Calendars < BaseResource
    include Operations::Create
    include Operations::Find
    include Operations::List
    include Operations::Update
    include Operations::Destroy
    # include other mixins as needed

    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end
  end
end
