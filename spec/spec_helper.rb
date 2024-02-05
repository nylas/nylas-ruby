# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "simplecov-cobertura"
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

require "nylas"
require "support/nylas_helpers"

RSpec.configure do |config|
  # Include the NylasHelpers module in all example groups
  config.include NylasHelpers
end
