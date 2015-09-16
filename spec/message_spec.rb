require 'message'
require 'folder'

describe Inbox::Message do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#as_json" do
    it "only includes starred, unread and labels/folder info" do
      msg = Inbox::Message.new(@inbox)
      msg.subject = 'Test message'
      msg.unread = true
      msg.starred = false

      labels = ['test label', 'label 2']
      labels.map! do |label|
        l = Inbox::Label.new(@inbox)
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
      msg = Inbox::Message.new(@inbox)
      msg.subject = 'Test event'
      msg.folder = labels[0]
      dict = msg.as_json
      expect(dict.length).to eq(1)
      expect(dict['labels']).to eq(nil)
      expect(dict['folder']).to eq('test label')

    end
  end

  describe "#raw" do
    it "requests the raw contents by setting an Accept header" do
      url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/messages/2/"
      stub_request(:get, url).
       with(:headers => {'Accept'=>'message/rfc822'}).
         to_return(:status => 200, :body => "Raw body", :headers => {})

      msg = Inbox::Message.new(@inbox, nil)
      msg.subject = 'Test message'
      msg.id = 2
      expect(msg.raw).to eq('Raw body')
      expect(a_request(:get, url)).to have_been_made.once
    end

    it "raises an error when getting an API error" do
      url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/messages/2/"
      stub_request(:get, url).
       with(:headers => {'Accept'=>'message/rfc822'}).
         to_return(:status => 404, :body => "Raw body", :headers => {})

      msg = Inbox::Message.new(@inbox, nil)
      msg.subject = 'Test message'
      msg.id = 2
      expect{ msg.raw }.to raise_error(Inbox::ResourceNotFound)
      expect(a_request(:get, url)).to have_been_made.once
    end
  end
end
