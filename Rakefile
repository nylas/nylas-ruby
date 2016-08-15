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

class Jeweler::Commands::ReleaseGemspec
  def commit_gemspec!
    # disable commiting the gemspec
  end
end

def define_jeweler_task(name)
  Jeweler::Tasks.new do |gem|
    gem.name = name
    gem.homepage = "http://github.com/nylas/nylas-ruby"
    gem.license = "MIT"
    gem.summary = %Q{Gem for interacting with the Nylas API}
    gem.description = %Q{Gem for interacting with the Nylas API.}
    gem.email = "ben@nylas.com"
    gem.authors = ["Ben Gotow", "Karim Hamidou", "Jennie Lees"]
    gem.files = Dir.glob('lib/**/*.rb')
    gem.version = Inbox::VERSION
    gem.platform = 'java' if RUBY_PLATFORM[/java/] == 'java'
    gem.dependencies.clear
    bundler = Bundler.load
    bundler.dependencies_for(:default, :runtime).each do |dependency|
      next unless dependency.current_platform?
      gem.add_dependency dependency.name, *dependency.requirement.as_list
    end

    bundler.dependencies_for(:development, :test).each do |dependency|
      next unless dependency.current_platform?
      gem.add_development_dependency dependency.name, *dependency.requirement.as_list
    end
  end
end

task :inbox_build do
  define_jeweler_task('inbox')

  Jeweler::RubygemsDotOrgTasks.new
  Rake::Task["gemspec"].invoke
  Rake::Task["build"].invoke
end

task :nylas_build do
  define_jeweler_task('nylas')

  Jeweler::RubygemsDotOrgTasks.new
  Rake::Task["gemspec"].invoke
  Rake::Task["build"].invoke
end


task :inbox_release => :inbox_build do
  Rake::Task["release"].invoke
end

task :nylas_release => :nylas_build do
  puts "\033[94mDid you run the self-test programs before releasing the gem?\033[0m"
  Rake::Task["release"].invoke
end

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
