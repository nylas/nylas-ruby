# frozen_string_literal: true

require "./lib/nylas/version"

# Consistently apply nylas' standard gem data across gems
module GemConfig
  def self.apply(gem)
    gem.description = %(Gem for interacting with the Nylas API.)
    gem.files = Dir.glob("lib/{nylas.rb,nylas/**/*.rb}")
    gem.license = "MIT"
    gem.version = Nylas::VERSION
    gem.platform = "ruby"
    gem.required_ruby_version = ">= 3.0"
    gem.metadata = metadata
    add_author_info(gem)
    dev_dependencies.each do |dependency|
      gem.add_development_dependency(*dependency)
    end
  end

  def self.add_author_info(gem)
    gem.email = "support@nylas.com"
    gem.authors = ["Nylas, Inc."]
  end

  def self.metadata
    {
      "bug_tracker_uri" => "https://github.com/nylas/nylas-ruby/issues",
      "changelog_uri" => "https://github.com/nylas/nylas-ruby/blob/master/CHANGELOG.md",
      "documentation_uri" => "https://developer.nylas.com/docs/sdks/ruby/",
      "homepage_uri" => "https://www.nylas.com",
      "source_code_uri" => "https://github.com/nylas/nylas-ruby",
      "github_repo" => "https://github.com/nylas/nylas-ruby"
    }
  end

  def self.dev_dependencies
    [["bundler", ">= 1.3.0"],
     ["yard", "~> 0.9.34"],
     ["rubocop", "~> 1.51"],
     ["rubocop-rspec", "~> 2.22"],
     ["rubocop-capybara", "~> 2.20"]] + testing_and_debugging_dependencies
  end

  def self.testing_and_debugging_dependencies
    [["rspec", "~> 3.12"],
     ["rspec-json_matcher", "~> 0.2.0"],
     ["webmock", "~> 3.18", ">= 3.18.1"],
     ["simplecov", "~> 0.22.0"],
     ["simplecov-cobertura", "~> 2.1.0"],
     ["webrick", "~> 1.8", ">= 1.8.1"]]
  end
end
