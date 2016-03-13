source 'https://rubygems.org'

gem 'rest-client', '~> 1.6'
gem 'yajl-ruby', platform: :ruby
gem 'em-http-request'
gem 'http', platform: :jruby
gem 'lock_jar'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development, :test do
  gem 'rspec'
  gem "shoulda", ">= 0"
  gem "rdoc", "~> 3.12"
  gem "bundler", ">= 1.3.5"
  gem "jeweler", "~> 1.8.4"
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-stack_explorer', platform: :ruby
  gem 'webmock'
  gem 'sinatra'
end

@@check ||= at_exit do
  begin
    require 'lock_jar/bundler'
    LockJar::Bundler.lock!(::Bundler)
  rescue
    # noop
  end
end
