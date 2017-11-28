require 'nylas'

describe Nylas::V1::Message do
  include Nylas::V1
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Nylas::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#as_json" do
    it "only includes starred, unread and labels/folder info" do
      msg = Message.new(@inbox)
      msg.subject = 'Test message'
      msg.unread = true
      msg.starred = false

      labels = ['test label', 'label 2']
      labels.map! do |label|
        l = Label.new(@inbox)
        l.id = label
        l
      end

      msg.labels = labels
      dict = msg.as_json
      expect(dict.length).to eq(3)
      expect(dict['unread']).to eq(true)
      expect(dict['starred']).to eq(false)
      expect(dict['label_ids']).to eq(['test label', 'label 2'])

      # Now check that we do the same if @folder is set.
      msg = Message.new(@inbox)
      msg.subject = 'Test event'
      msg.folder = labels[0]
      dict = msg.as_json
      expect(dict.length).to eq(1)
      expect(dict['labels']).to eq(nil)
      expect(dict['folder_id']).to eq('test label')

    end
  end

  describe "#raw" do
    it "requests the raw contents by setting an Accept header" do
      url = "https://api.nylas.com/messages/2/"
      stub_request(:get, url).with(basic_auth: [@access_token]).
       with(:headers => {'Accept'=>'message/rfc822'}).
         to_return(:status => 200, :body => "Raw body", :headers => {})

      msg = Message.new(@inbox, nil)
      msg.subject = 'Test message'
      msg.id = 2
      expect(msg.raw).to eq('Raw body')
      expect(a_request(:get, url)).to have_been_made.once
    end

    it "raises an error when getting an API error" do
      url = "https://api.nylas.com/messages/2/"
      stub_request(:get, url).with(basic_auth: [@access_token]).
       with(:headers => {'Accept'=>'message/rfc822'}).
         to_return(:status => 404,
                   :body => '{"message": "404: Not Found",' +
                              '"type": "api_error"}',
                   :headers => {})

      msg = Message.new(@inbox, nil)
      msg.subject = 'Test message'
      msg.id = 2
      expect{ msg.raw }.to raise_error(ResourceNotFound)
      expect(a_request(:get, url)).to have_been_made.once
    end
  end

  describe "#expanded" do
    it "requests the expanded version of the message" do
      url = "https://api.nylas.com/messages/2/?view=expanded"
      stub_request(:get, url).with(basic_auth: [@access_token]).
        to_return(:status  => 200,
                  :body    => File.read('spec/fixtures/expanded_message.txt'),
                  :headers => {})

      msg = Message.new(@inbox, nil)
      msg.id = 2
      expanded = msg.expanded
      expect(expanded.message_id).to eq('<55afa28c.c136460a.49ae.ffff80fd@mx.google.com>')
      expect(expanded.in_reply_to).to be_nil
    end
  end

  describe "#files?" do
    it "returns false when the message has no attached files" do
      msg = Message.new(@inbox)
      msg.inflate({'files' => []})
      expect(msg.files?).to be false
    end

    it "returns true when the message has attached files" do
      msg = Message.new(@inbox)
      msg.inflate({'files' => ['1', '2']})
      expect(msg.files?).to be true
    end
  end

  describe "#mark_read!" do
    it "issues a PUT request to update the thread" do
      url = "https://api.nylas.com/messages/2"
      stub_request(:put, url).with(basic_auth: [@access_token]).
        to_return(:status => 200, :body => '{"unread": false}')

      msg = Message.new(@inbox, nil)
      msg.id = 2
      msg.mark_as_read!
      expect(a_request(:put, url)).to have_been_made.once
      expect(msg.unread).to be false
    end
  end

  describe "#star!" do
    it "issues a PUT request to update the message" do
      url = "https://api.nylas.com/messages/2"
      stub_request(:put, url).with(basic_auth: [@access_token]).
        to_return(:status => 200, :body => '{"starred": true}')

      msg = Message.new(@inbox, nil)
      msg.id = 2
      msg.star!
      expect(a_request(:put, url)).to have_been_made.once
      expect(msg.starred).to be true
    end
  end
end
