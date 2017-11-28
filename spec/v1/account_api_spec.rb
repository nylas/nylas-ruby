require 'nylas'

describe Nylas::V1::APIAccount do
  let(:inbox) { Nylas::API.new(app_id, app_secret, access_token) }
  let(:app_id) { 'ABC' }
  let(:app_secret) { '123' }
  let(:access_token) { 'UXXMOCJW-BKSLPCFI-UQAQFWLO' }

  describe "Nylas#account" do
    it "does a request to /account" do
      url = "https://api.nylas.com/account"
      stub = stub_request(:get, url).with(basic_auth: [access_token]).
           to_return(:status => 200, :body => File.read('spec/fixtures/account_api.txt'), :headers => {})

      acc = inbox.account
      expect(a_request(:get, url)).to have_been_made.once
      expect(acc.provider).to eq('eas')
      expect(acc.sync_state).to eq('running')
    end
  end
end
