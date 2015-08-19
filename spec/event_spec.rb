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

  describe "#as_json" do
    it "doesn't include nil values" do
      ev = Inbox::Event.new(@inbox)
      ev.title = 'Test event'
      ev.description = nil
      dict = ev.as_json
      expect(dict['title']).to eq('Test event')
      expect(dict.length).to eq(1)
    end

    it "does remove object: timespan fields from 'when' blocks" do
      ev = Inbox::Event.new(@inbox)
      ev.title = 'Test event'
      ev.when = {'start_time' => 12345675, 'end_time' => 2345678, 'object' => 'timespan'}
      dict = ev.as_json

      expect(dict['when'].length).to eq(2)
      expect(dict['when'].has_key?('object')).to be false
    end
  end

  describe "#rsvp!" do
    it "does a request to /send-rsvp" do
      url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/send-rsvp"
      stub = stub_request(:post, url).
           to_return(:status => 200, :body => File.read('spec/fixtures/rsvp_reply.txt'), :headers => {})

      ev = Inbox::Event.new(@inbox)
      ev.id = 'public_id'
      ev.rsvp!('yes', 'I will come.')

      expect(a_request(:post, url).
        with(:body => '{"event_id":"public_id","status":"yes","comment":"I will come."}')).to have_been_made.once
      end
    end
end
