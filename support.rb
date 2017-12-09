require "./lib/nylas/version"

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
def configure_gem(gem, name)
  gem.name = name
  gem.homepage = "http://github.com/nylas/nylas-ruby"
  gem.license = "MIT"

  gem.version = Nylas::VERSION
  gem.email = "support@nylas.com"
  gem.authors = ["Nylas, Inc."]
  gem.files = Dir.glob("lib/{#{name}.rb,#{name}/**/*.rb}")
  gem.platform = "ruby"

  gem.metadata = {
    "bug_tracker_uri"   => "https://github.com/nylas/nylas-ruby/issues",
    "changelog_uri"     => "https://github.com/nylas/nylas-ruby/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://www.rubydoc.info/gems/nylas",
    "homepage_uri"      => "https://www.nylas.com",
    "source_code_uri"   => "https://github.com/nylas/nylas-ruby",
    "wiki_uri"          => "https://github.com/nylas/nylas-ruby/wiki"
  }

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "jeweler", "~> 2.1"
  gem.add_development_dependency "yard", "~> 0.9.0"

  gem.add_development_dependency "pry", "~>  0.10.4"
  gem.add_development_dependency "pry-nav", "~> 0.2.4"
  gem.add_development_dependency "pry-stack_explorer", "~> 0.4.9"

  gem.add_development_dependency "rspec", "~> 3.7"
  gem.add_development_dependency "webmock", "~> 3.0"

  gem.add_development_dependency "awesome_print", "~> 1.0"
  gem.add_development_dependency "faker", "~> 1.8"
  gem.add_development_dependency "informed", "~> 1.0"
  gem.add_development_dependency "rubocop", "~> 0.46.0"
  gem.add_development_dependency "rubocop-rspec", "~> 1.8.0"
  gem.add_development_dependency "simplecov", "~> 0.15"

  gem.add_development_dependency "overcommit", "~> 0.41"
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
