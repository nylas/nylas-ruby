::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'message'
require 'folder'

describe Inbox::Message do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret)
  end

  describe "#as_json" do
    it "only includes starred, unread and labels/folder info" do
      msg = Inbox::Message.new(@inbox, nil)
      msg.subject = 'Test event'
      msg.unread = true
      msg.starred = false

      labels = ['test label', 'label 2']
      labels.map! do |label|
        l = Inbox::Label.new(@inbox, nil)
        l.id = label
        l
      end

      msg.labels = labels
      dict = msg.as_json
      expect(dict.length).to eq(3)
      expect(dict['unread']).to eq(true)
      expect(dict['starred']).to eq(false)
      expect(dict['labels']).to eq(['test label', 'label 2'])

      # Now check that we do the same if @folder is set.
      msg = Inbox::Message.new(@inbox, nil)
      msg.subject = 'Test event'
      msg.folder = labels[0]
      dict = msg.as_json
      expect(dict.length).to eq(1)
      expect(dict['labels']).to eq(nil)
      expect(dict['folder']).to eq('test label')

    end
  end
end
