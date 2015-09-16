::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'event'

describe Inbox::APIAccount do
  before (:each) do
    @inbox = Inbox::API.new(nil, nil, nil, 'http://localhost:5555')

    @base_url = "http://localhost:5555/accounts?limit=100&offset=0"
    stub_request(:get, @base_url).to_return(
      :status => 200,
      :body => File.read('spec/fixtures/opensource_accounts_endpoint.txt'),
      :headers => {"Content-Type" => "application/json"})
  end

  describe "list" do
    it "should list the available accounts" do
      accounts = @inbox.accounts.all
      assert_requested :get, @base_url
      expect(accounts.length).to eq(1)
      expect(accounts[0].id).to eq('1qqlrm3m82toh86nevz0o1l24')
    end
  end
end
