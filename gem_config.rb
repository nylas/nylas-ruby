# frozen_string_literal: true

require "./lib/nylas/version"

# Consistently apply nylas' standard gem data across gems
module GemConfig
  def self.apply(gem, name)
    gem.name = name
    gem.files = Dir.glob("lib/{#{name}.rb,#{name}/**/*.rb}")
    gem.license = "MIT"
    gem.version = Nylas::VERSION
    gem.platform = "ruby"
    gem.required_ruby_version = ">= 3.0"
    append_nylas_data(gem)
    dev_dependencies.each do |dependency|
      gem.add_development_dependency(*dependency)
    end
  end

  def self.append_nylas_data(gem)
    gem.metadata = metadata
    gem.email = "support@nylas.com"
    gem.authors = ["Nylas, Inc."]
  end

  def self.metadata
    {
      "bug_tracker_uri" => "https://github.com/nylas/nylas-ruby/issues",
      "changelog_uri" => "https://github.com/nylas/nylas-ruby/blob/master/CHANGELOG.md",
      "documentation_uri" => "http://www.rubydoc.info/gems/nylas",
      "homepage_uri" => "https://www.nylas.com",
      "source_code_uri" => "https://github.com/nylas/nylas-ruby",
      "wiki_uri" => "https://github.com/nylas/nylas-ruby/wiki"
    }
  end

  def self.dev_dependencies
    [["bundler", ">= 1.3.0"],
     ["yard", "~> 0.9.0"],
     ["awesome_print", "~> 1.0"],
     ["rubocop", "~> 1.24.1"],
     ["rubocop-rspec", "~> 2.7.0"],
     ["overcommit", "~> 0.41"]] + testing_and_debugging_dependencies
  end

  def self.testing_and_debugging_dependencies
    [["pry", "~>  0.14.1"],
     ["pry-nav", "~> 1.0.0"],
     ["pry-stack_explorer", "~> 0.4.9.3"],
     ["rspec", "~> 3.7"],
     ["rspec-json_matcher", "~> 0.1"],
     ["webmock", "~> 3.0"],
     ["faker", "~> 1.8"],
     ["informed", "~> 1.0"],
     ["simplecov", "~> 0.21.2"],
     ["simplecov-cobertura", "~> 2.1.0"]]
  end
end
