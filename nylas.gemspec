# frozen_string_literal: true

require "./gem_config"

Gem::Specification.new do |gem|
  GemConfig.apply(gem, "nylas")
  gem.summary = %(Gem for interacting with the Nylas API)
  gem.description = %(Gem for interacting with the Nylas API.)
  gem.add_runtime_dependency "rest-client", ">= 2.0", "< 3.0"
  gem.add_runtime_dependency "yajl-ruby", "~> 1.2", ">= 1.2.1"
end
