::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'event'
require 'webmock/rspec'

describe Inbox::Event do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe "Inbox#account" do
    it "does a request to /account" do
      url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/account"
      stub = stub_request(:get, url).
           to_return(:status => 200, :body => File.read('spec/fixtures/account_api.txt'), :headers => {})

      acc = @inbox.account
      expect(a_request(:get, url)).to have_been_made.once
      expect(acc.provider).to eq('eas')
    end
  end
end
