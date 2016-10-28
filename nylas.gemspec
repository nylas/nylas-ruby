# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require './lib/version.rb'

Gem::Specification.new do |gem|
  gem.name = 'nylas'
  gem.homepage = 'http://github.com/nylas/nylas-ruby'
  gem.license = 'MIT'
  gem.summary = %Q{Gem for interacting with the Nylas API}
  gem.description = %Q{Gem for interacting with the Nylas API.}
  gem.version = Nylas::VERSION
  gem.email = "support@nylas.com"
  gem.authors = ["Ben Gotow", "Karim Hamidou", "Jennie Lees", "Michael Pfister"]
  gem.files = Dir.glob('lib/**/*.rb')
  gem.platform = 'java' if RUBY_PLATFORM[/java/] == 'java'
  gem.dependencies.clear
  bundler = Bundler.load
  bundler.dependencies_for(:default, :runtime).each do |dependency|
    next unless dependency.current_platform?
    gem.add_runtime_dependency dependency.name, *dependency.requirement.as_list
  end
  bundler.dependencies_for(:development, :test).each do |dependency|
    next unless dependency.current_platform?
    gem.add_development_dependency dependency.name, *dependency.requirement.as_list
  end
end
