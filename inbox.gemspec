# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inbox/version'

Gem::Specification.new do |spec|
  spec.name          = "inbox"
  spec.version       = Inbox::VERSION
  spec.authors       = ["Team Inbox"]
  spec.email         = ["support@inboxapp.com"]
  spec.summary       = "Ruby bindings for the Inbox API"
  spec.description   = "Inbox is the next-generation email platform. See https://inboxapp.com for details."
  spec.homepage      = "https://www.inboxapp.com/docs"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "rake"
end
