source 'https://rubygems.org'

gem 'activesupport', '~> 5.0', '>= 5.0.0.1'
gem 'rest-client', '~> 1.6'
gem 'yajl-ruby', '~> 1.2', '>= 1.2.1', platform: :ruby
gem 'em-http-request', '~> 1.1', '>= 1.1.3', platform: :ruby
gem 'sjs', '~> 0.2.1', platform: :jruby

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development, :test do
  gem 'rspec', '~> 3.5', '>= 3.5.0'
  gem "shoulda", '~> 3.5', '>= 3.4.0'
  gem "rdoc", "~> 3.12"
  gem 'bundler', '~> 1.3', '>= 1.3.5'
  gem 'jeweler', '~> 2.1', '>= 2.1.2'
  gem 'pry', '~> 0.10.4'
  gem 'pry-nav', '~> 0.2.4'
  gem 'pry-stack_explorer', '~> 0.4.9.2', platform: :ruby
  gem 'webmock', '~> 2.1', '>= 2.1.0'
  gem 'sinatra', '~> 1.4', '>= 1.4.7'
end

@@check ||= at_exit do
  # JRuby only.Generate Jarfile.lock which is used by LockJar to load jar
  # dependencies into the classpath.
  if RUBY_PLATFORM[/java/] == 'java'
    require 'lock_jar/bundler'
    LockJar::Bundler.lock!(::Bundler)
  end
end
