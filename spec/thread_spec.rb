require 'thread'
require 'folder'

describe Inbox::Thread do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#as_json" do
    it "only includes labels/folder info" do
      thr = Inbox::Thread.new(@inbox, nil)
      thr.subject = 'Test event'

      labels = ['test label', 'label 2']
      labels.map! do |label|
        l = Inbox::Label.new(@inbox, nil)
        l.id = label
        l
      end

      thr.labels = labels
      dict = thr.as_json
      expect(dict.length).to eq(1)
      expect(dict['label_ids']).to eq(['test label', 'label 2'])

      # Now check that we do the same if @folder is set.
      thr = Inbox::Thread.new(@inbox, nil)
      thr.subject = 'Test event'
      thr.folder = labels[0]
      dict = thr.as_json
      expect(dict.length).to eq(1)
      expect(dict['label_ids']).to eq(nil)
      expect(dict['folder_id']).to eq('test label')

    end
  end

  describe "#mark_read!" do
    it "issues a PUT request to update the thread" do
      url = "https://#{@access_token}:@api.nylas.com/threads/2"
      stub_request(:put, url).to_return(:status => 200, :body => '{"unread": false}')

      th = Inbox::Thread.new(@inbox, nil)
      th.id = 2
      th.mark_as_read!
      expect(a_request(:put, url)).to have_been_made.once
      expect(th.unread).to be false
    end
  end

  describe "#star!" do
    it "issues a PUT request to update the thread" do
      url = "https://#{@access_token}:@api.nylas.com/threads/2"
      stub_request(:put, url).to_return(:status => 200, :body => '{"starred": true}')

      th = Inbox::Thread.new(@inbox, nil)
      th.id = 2
      th.star!
      expect(a_request(:put, url)).to have_been_made.once
      expect(th.starred).to be true
    end
  end
end
