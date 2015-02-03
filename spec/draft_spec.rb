::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'event'

describe Inbox::Event do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    stub_request(:post, "https://#{@access_token}:@api.nilas.com/n/#{@namespace_id}/send").to_return(
             :status => 200,
             :body => File.read('spec/fixtures/send_endpoint.txt'),
             :headers => {"Content-Type" => "application/json"})
  end

  describe "#send!" do
    it "does return a fully-formed draft object after sending it" do
      draft = Inbox::Draft.new(@inbox, @namespace_id)
      expect(draft.id).to be nil

      result = draft.send!
      expect(result.id).to_not be nil
      expect(result.snippet).to_not be ""
    end
  end

end
