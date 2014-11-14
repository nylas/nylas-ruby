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
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "inbox"
  gem.homepage = "http://github.com/inboxapp/inbox-ruby"
  gem.license = "MIT"
  gem.summary = %Q{Gem for interacting with the Inbox API}
  gem.description = %Q{Gem for interacting with the Inbox API that allows you to create and publish one-page websites, subscribe to web hooks and receive events when those pages are interacted with. Visit http://www.populr.me/ for more information. }
  gem.email = "ben@inboxapp.com"
  gem.authors = ["Ben Gotow"]
  gem.files = Dir.glob('lib/**/*.rb')
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
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "inbox #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :console do
  exec "irb -r inbox -I ./lib"
end
