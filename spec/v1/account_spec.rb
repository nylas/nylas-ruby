require 'nylas'

describe Nylas::V1::Account do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Nylas::API.new(@app_id, @app_secret, @access_token)

    uri_template = Addressable::Template.new "https://api.nylas.com/a/#{@app_id}/accounts{?limit,offset}"
    stub_request(:get, uri_template).with(basic_auth: [@app_secret]).to_return(
      :status => 200,
      :body => File.read('spec/fixtures/accounts_endpoint.txt'),
      :headers => {"Content-Type" => "application/json"})

    @account_detail_url = "https://api.nylas.com/a/#{@app_id}/accounts/awa6ltos76vz5hvphkp8k17nt"
    @upgrade_url = "https://api.nylas.com/a/#{@app_id}/accounts/awa6ltos76vz5hvphkp8k17nt/upgrade"
    @downgrade_url = "https://api.nylas.com/a/#{@app_id}/accounts/awa6ltos76vz5hvphkp8k17nt/downgrade"
    stub_request(:get, @account_detail_url).
      with(basic_auth: [@app_secret]).
      to_return(
      :status => 200, :headers => {"Content-Type" => "application/json"},
      :body => '{
        "account_id": "4n51fjmy9tjlra69s5wmcd9ji",
        "billing_state": "free",
        "id": "4n51fjmy9tjlra69s5wmcd9ji",
        "namespace_id": "a0dxkqyd9ah77gof3nouuwak9",
        "sync_state": "running",
        "trial": false
    }')
    stub_request(:post, @upgrade_url).
      with(basic_auth: [@app_secret]).
      to_return(
      :status => 200, :headers => {"Content-Type" => "application/json"}, :body => "{}")

    stub_request(:post, @downgrade_url).
      with(basic_auth: [@app_secret]).
      to_return(
      :status => 200, :headers => {"Content-Type" => "application/json"}, :body => "{}")

  end

  describe "find" do
    it "should call the correct URL" do
      @inbox.accounts.find("awa6ltos76vz5hvphkp8k17nt")
      assert_requested :get, @account_detail_url
    end
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
