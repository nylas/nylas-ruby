::ENV['RACK_ENV'] = 'test'
require 'thread'
require 'folder'

describe Inbox::Thread do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret)
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
      expect(dict['labels']).to eq(['test label', 'label 2'])

      # Now check that we do the same if @folder is set.
      thr = Inbox::Thread.new(@inbox, nil)
      thr.subject = 'Test event'
      thr.folder = labels[0]
      dict = thr.as_json
      expect(dict.length).to eq(1)
      expect(dict['labels']).to eq(nil)
      expect(dict['folder']).to eq('test label')

    end
  end
end
