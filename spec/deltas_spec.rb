require 'event'

describe 'Delta sync API wrapper' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    @generate_url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/generate_cursor"
    stub_request(:post, @generate_url).
         to_return(:status => 200, :body => File.read('spec/fixtures/initial_cursor.txt'), :headers => {})

    @latest_url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/latest_cursor"
    stub_request(:post, @latest_url).
         to_return(:status => 200, :body => File.read('spec/fixtures/latest_cursor.txt'), :headers => {})

    @cursor_zero_url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta?cursor=0"
    stub_request(:get, @cursor_zero_url).
         to_return(:status => 200, :body => File.read('spec/fixtures/first_cursor.txt'), :headers => {'Content-Type' => 'application/json'})

    @nth_cursor_url = "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta?cursor=a9vtneydekzye7uwfumdd4iu3"
    stub_request(:get, @nth_cursor_url).
         to_return(:status => 200, :body => File.read('spec/fixtures/second_cursor.txt'), :headers => {})

  end

  it "should get the initial cursor" do
    @inbox.get_cursor(timestamp=0)
    expect(a_request(:post, @generate_url)).to have_been_made.once
  end

  it "should get the latest cursor" do
    cursor = @inbox.latest_cursor
    expect(cursor).to eq('cx7ln1akyj2qgdu6o5d5bakuw')
  end

  it "should continuously query the delta sync API" do
    count = 0
    @inbox.deltas(timestamp=0) do |event, object|
      expect(object.cursor).to_not be_nil
      if event == 'create' or event == 'modify'
        expect(object).to be_a Inbox::Message
      elsif event == 'delete'
        expect(object).to be_a Inbox::Event
      end
      count += 1
    end

    expect(a_request(:get, @cursor_zero_url)).to have_been_made.once
    expect(a_request(:get, @nth_cursor_url)).to have_been_made.once
    expect(count).to eq(3)
  end

  it 'will filter deltas based on the specified exclude types' do
    stub_request(:get, 'https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta?cursor=a9vtneydekzye7uwfumdd4iu3&exclude_types=calendar,event,tag').
      to_return(status: 200, body: File.read('spec/fixtures/second_cursor.txt'), headers: {'Content-Type' => 'application/json'})

    filters = [Inbox::Calendar, Inbox::Event, Inbox::Tag, 'FakeFilter']
    @inbox.deltas('a9vtneydekzye7uwfumdd4iu3', filters) do |event, object|
      expect(object.cursor).to_not be_nil
    end
  end
end

describe 'Delta sync streaming API wrapper' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/streaming?cursor=0").
      to_return(:status => 200, :body => File.read('spec/fixtures/delta_stream.txt'), :headers => {'Content-Type' => 'application/json'})
  end

  it "should continuously query the delta sync API" do
    count = 0
    @inbox.delta_stream(0, []) do |event, object|

      expect(object.cursor).to_not be_nil
      if event == 'create' or event == 'modify'
        expect(object).to be_a Inbox::Message
      elsif event == 'delete'
        expect(object).to be_a Inbox::Event
      end
      count += 1
      break if count == 3
    end

    expect(count).to eq(3)
  end
end

describe 'Delta sync bogus requests' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)

    stub_request(:post, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/generate_cursor").
         to_return(:status => 200, :body => File.read('spec/fixtures/initial_cursor.txt'), :headers => {})

    stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta?cursor=0").
         to_return(:status => 200, :body => File.read('spec/fixtures/bogus_second.txt'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/streaming?cursor=0").
      to_return(:status => 200, :body => File.read('spec/fixtures/bogus_stream.txt'), :headers => {'Content-Type' => 'application/json'})
  end

  it "delta sync should skip bogus requests" do
    count = 0
    @inbox.deltas(timestamp=0, []) do |event, object|
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

  it "delta stream should skip bogus requests" do
    count = 0
    @inbox.delta_stream(0, []) do |event, object|
      expect(object.cursor).to_not be_nil
      if event == 'create' or event == 'modify'
        expect(object).to be_a Inbox::Message
      elsif event == 'delete'
        expect(object).to be_a Inbox::Event
        break
      end

      count += 1
    end

    expect(count).to eq(1)
  end
end
