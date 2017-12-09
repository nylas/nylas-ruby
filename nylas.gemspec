require "./support"

Gem::Specification.new do |gem|
  configure_gem(gem, "nylas")
  gem.summary = %(Gem for interacting with the Nylas API)
  gem.description = %(Gem for interacting with the Nylas API.)
  gem.add_runtime_dependency "rest-client", ">= 1.6", "< 3.0"
end
