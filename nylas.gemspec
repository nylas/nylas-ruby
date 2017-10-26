# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
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
  gem.platform = 'ruby'

  gem.add_runtime_dependency 'rest-client', '~> 2.0'
  gem.add_runtime_dependency 'yajl-ruby', '~> 1.2', '>= 1.2.1'
  gem.add_runtime_dependency 'em-http-request', '~> 1.1', '>= 1.1.3'

  gem.add_development_dependency 'rest-client', '~> 2.0'
  gem.add_development_dependency 'yajl-ruby', '~> 1.2', '>= 1.2.1'
  gem.add_development_dependency 'em-http-request', '~> 1.1', '>= 1.1.3'
  gem.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'
  gem.add_development_dependency "shoulda", '~> 3.5', '>= 3.4.0'
  gem.add_development_dependency "rdoc", "~> 3.12"
  gem.add_development_dependency 'bundler', '~> 1.3', '>= 1.3.5'
  gem.add_development_dependency 'jeweler', '~> 2.1', '>= 2.1.2'
  gem.add_development_dependency 'pry', '~> 0.10.4'
  gem.add_development_dependency 'pry-nav', '~> 0.2.4'
  gem.add_development_dependency 'pry-stack_explorer', '~> 0.4.9.2'
  gem.add_development_dependency 'webmock', '~> 2.1', '>= 2.1.0'
  gem.add_development_dependency 'sinatra', '~> 1.4', '>= 1.4.7'
end
