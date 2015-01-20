::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'event'

describe Inbox::Account do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    uri_template = Addressable::Template.new "https://#{@app_secret}:@api.inboxapp.com/a/#{@app_id}/accounts/{?limit,offset}"
    stub_request(:get, uri_template).to_return(
      :status => 200,
      :body => File.read('spec/fixtures/accounts_endpoint.txt'),
      :headers => {"Content-Type" => "application/json"})

    @upgrade_url = "https://#{@app_secret}:@api.inboxapp.com/a/#{@app_id}/accounts/awa6ltos76vz5hvphkp8k17nt/upgrade"
    @downgrade_url = "https://#{@app_secret}:@api.inboxapp.com/a/#{@app_id}/accounts/awa6ltos76vz5hvphkp8k17nt/downgrade"
    stub_request(:post, @upgrade_url).to_return(
      :status => 200, :headers => {"Content-Type" => "application/json"}, :body => "{}")

    stub_request(:post, @downgrade_url).to_return(
      :status => 200, :headers => {"Content-Type" => "application/json"}, :body => "{}")

  end

  describe "#upgrade!" do
    it "should call the correct URL" do
      account = @inbox.accounts.first
      account.upgrade!
      assert_requested :post, @upgrade_url
    end
  end

  describe "#downgrade!" do
    it "should call the correct URL" do
      account = @inbox.accounts.first
      account.downgrade!
      assert_requested :post, @downgrade_url
    end
  end

end
