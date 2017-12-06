require 'nylas/message'
require 'nylas/folder'

describe Nylas::Message do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Nylas::API.new(app_id: @app_id, app_secret: @app_secret, access_token: @access_token)
  end

  describe "#date=" do
    it "casts the date object to a string for backwards compatibility reasons" do
      msg = Nylas::Message.new(@inbox)
      msg.date = Date.parse('2017-01-01')
      expect(msg.date).to eql Date.parse('2017-01-01').strftime('%s').to_i
    end
  end

  describe '#parsed_date' do
    it "exposes the `date` field as a true ruby date object" do
      msg = Nylas::Message.new(@inbox)
      msg.date = '2017-01-01 01:00:00Z'
      expect(msg.parsed_date).to eql DateTime.parse('2017-01-01 01:00:00Z')
    end


    it "supports dates set as unix timestamps" do
      msg = Nylas::Message.new(@inbox)
      msg.date = 1511305289
      expect(msg.parsed_date).to eql Time.at(msg.date).to_datetime
    end
  end

  describe "#as_json" do
    it "doesn't send the the labels ids if the labels are empty" do
      labels = []
      message = Nylas::Message.new(@inbox)
      message.labels = labels
      expect(message.as_json).not_to have_key("label_ids")
    end

    it "raises a useful error of the labels are set but don't respond to id" do
      labels = [double(anything_that_doesnt_respond_to_id: nil)]
      message = Nylas::Message.new(@inbox)
      message.labels = labels
      expect { message.as_json }.to raise_error(TypeError, "label #{labels.first} does not respond to #id")
    end

    it "doesn't send the folder id when folder is nil" do
      folder = nil
      message = Nylas::Message.new(@inbox)
      message.folder = folder
      expect(message.as_json).not_to have_key("folder_id")
    end

    it "sends the folders id when folder is an object that responds to id" do
      folder = double(id: :some_id)
      message = Nylas::Message.new(@inbox)
      message.folder = folder
      expect(message.as_json["folder_id"]).to eql :some_id
    end

    it "raises a useful error if folder is not nil or it doesn't respond to id" do
      folder = double(anything_that_doesnt_respond_to_id: nil)
      message = Nylas::Message.new(@inbox)
      message.folder = folder
      expect { message.as_json }.to raise_error(TypeError, "folder #{folder} does not respond to #id")
    end

    it "only includes starred, unread and labels/folder info" do
      msg = Nylas::Message.new(@inbox)
      msg.subject = 'Test message'
      msg.unread = true
      msg.starred = false

      labels = ['test label', 'label 2']
      labels.map! do |label|
        l = Nylas::Label.new(@inbox)
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
      msg = Nylas::Message.new(@inbox)
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

      msg = Nylas::Message.new(@inbox, nil)
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

      msg = Nylas::Message.new(@inbox, nil)
      msg.subject = 'Test message'
      msg.id = 2
      expect{ msg.raw }.to raise_error(Nylas::ResourceNotFound)
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

      msg = Nylas::Message.new(@inbox, nil)
      msg.id = 2
      expanded = msg.expanded
      expect(expanded.message_id).to eq('<55afa28c.c136460a.49ae.ffff80fd@mx.google.com>')
      expect(expanded.in_reply_to).to be_nil
    end
  end


  describe "#events" do
    it "casts passed in event data to Nylas::Event objects" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({ "events" => [{"id" => "12345" }] })
      expect(msg.events.first).to be_a Nylas::Event
      expect(msg.events.first.id).to eql "12345"
    end

    it "raises a friendly error if event data can't be cast to `Nylas::Event`s" do
      msg = Nylas::Message.new(@inbox)
      non_event=double(:something_that_cant_be_cast_to_an_event)
      expect { msg.inflate({"events" => [non_event] }) }.to raise_error(TypeError, "unable to cast #{non_event} to an event.")
    end

    it "raises a friendly error if we can't map over the passed in event data" do
      msg = Nylas::Message.new(@inbox)
      non_enumerable=double(:something_that_cannot_be_mapped)
      expect { msg.inflate({ "events" => non_enumerable })}.to raise_error(TypeError, "unable to iterate over #{non_enumerable}, events must respond to #map")
    end

    it "sets the state directly if the passed in data quacks like a collection of Nylas::Event" do
      msg = Nylas::Message.new(@inbox)
      realish_events = [double(id: "I could be considered an event")]
      msg.inflate({ "events" => realish_events })

      expect(msg.events).to eql realish_events
    end
  end

  describe "#events?" do
    it "is false if no events are inflated" do
      msg = Nylas::Message.new(@inbox)
      expect(msg.events?).to be_falsey
    end

    it "is false if an empty set of events are inflated" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({ "events" => [] })
      expect(msg.events?).to be_falsey
    end

    it "is true if events are inflated" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({ "events" => [{"id" => "12345" }] })
      expect(msg.events?).to be_truthy
    end
  end

  describe "#files" do
    it "is a Restful model collection for retrieving events scoped to the message" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({'id' => '1234', 'files' => ['1', '2']})
      expect(msg.files.model_class).to eql Nylas::File
      expect(msg.files.filters).to eql({ message_id: '1234' })
      expect(msg.files._api).to eql @inbox
    end
  end

  describe "#files?" do
    it "returns false when the message has no attached files" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({'files' => []})
      expect(msg.files?).to be false
    end

    it "returns true when the message has attached files" do
      msg = Nylas::Message.new(@inbox)
      msg.inflate({'files' => ['1', '2']})
      expect(msg.files?).to be true
    end
  end

  describe "#mark_read!" do
    it "issues a PUT request to update the thread" do
      url = "https://api.nylas.com/messages/2"
      stub_request(:put, url).with(basic_auth: [@access_token]).
        to_return(:status => 200, :body => '{"unread": false}')

      msg = Nylas::Message.new(@inbox, nil)
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

      msg = Nylas::Message.new(@inbox, nil)
      msg.id = 2
      msg.star!
      expect(a_request(:put, url)).to have_been_made.once
      expect(msg.starred).to be true
    end
  end
end
