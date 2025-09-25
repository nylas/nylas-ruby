# frozen_string_literal: true

require "simplecov"
require "simplecov-cobertura"

SimpleCov.start do
  add_filter "/spec/"
  
  # Use multiple formatters to ensure coverage data is available
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ])
end

require "nylas"
require "support/nylas_helpers"

RSpec.configure do |config|
  # Include the NylasHelpers module in all example groups
  config.include NylasHelpers
end
