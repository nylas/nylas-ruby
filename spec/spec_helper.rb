# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "simplecov-cobertura"
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

require "nylas_v2"
require "support/nylas_v2_helpers"

RSpec.configure do |config|
  # Include the NylasV2Helpers module in all example groups
  config.include NylasV2Helpers
end
