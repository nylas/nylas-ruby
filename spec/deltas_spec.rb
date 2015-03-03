::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'namespace'
require 'event'

describe 'Delta sync API wrapper' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    stub_request(:post, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nilas.comn/nnnnnnn/delta/generate_cursor").
         to_return(:status => 200, :body => File.read('spec/fixtures/initial_cursor.txt'), :headers => {})

    stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nilas.comn/nnnnnnn/delta?cursor=0").
         to_return(:status => 200, :body => File.read('spec/fixtures/first_cursor.txt'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nilas.comn/nnnnnnn/delta?cursor=a9vtneydekzye7uwfumdd4iu3").
         to_return(:status => 200, :body => File.read('spec/fixtures/second_cursor.txt'), :headers => {})

  end

  it "should get the initial cursor" do
    ns = Inbox::Namespace.new(@inbox, @namespace_id)
    ns.get_cursor(timestamp=0)
  end

  it "should continuously query the delta sync API" do
    count = 0
    ns = Inbox::Namespace.new(@inbox, @namespace_id)
    ns.deltas(timestamp=0) do |event, object|

      expect(object.cursor).to_not be_nil
      if event == 'create' or event == 'modify'
        expect(object).to be_a Inbox::Message
      elsif event == 'delete'
        expect(object).to be_a Inbox::Event
      end
      count += 1
    end

    expect(count).to eq(3)
  end
end

