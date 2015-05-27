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
require 'rake'

require 'jeweler'
require './lib/version.rb'
# Jeweler::Tasks.new do |gem|
#   # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
#   gem.name = "inbox"
#   gem.homepage = "http://github.com/nylas/inbox-ruby"
#   gem.license = "MIT"
#   gem.summary = %Q{Gem for interacting with the Inbox API}
#   gem.description = %Q{Gem for interacting with the Inbox API.}
#   gem.email = "ben@nylas.com"
#   gem.authors = ["Ben Gotow", "Karim Hamidou", "Jennie Lees"]
#   gem.files = Dir.glob('lib/**/*.rb')
#   gem.version = Inbox::VERSION
# end
# 
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "nylas"
  gem.homepage = "http://github.com/nylas/inbox-ruby"
  gem.license = "MIT"
  gem.summary = %Q{Gem for interacting with the Inbox API}
  gem.description = %Q{Gem for interacting with the Inbox API.}
  gem.email = "ben@nylas.com"
  gem.authors = ["Ben Gotow", "Karim Hamidou", "Jennie Lees"]
  gem.files = Dir.glob('lib/**/*.rb')
  gem.version = Inbox::VERSION
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = Inbox::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "inbox #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :console do
  exec "irb -r inbox -I ./lib"
end
