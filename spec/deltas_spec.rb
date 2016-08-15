require 'event'

describe Inbox::API do
  subject(:inbox) { Inbox::API.new(app_id, app_secret, access_token) }
  let(:nth_cursor) { 'a9vtneydekzye7uwfumdd4iu3' }
  let(:app_id) { 'ABC' }
  let(:app_secret) { '123' }
  let(:access_token) { 'UXXMOCJW-BKSLPCFI-UQAQFWLO' }
  let(:api_url_template) { 'https://api.nylas.com/delta' }

  def api_url(resource)
    "#{api_url_template}#{resource}"
  end

  describe 'Delta sync API wrapper' do
    let(:latest_cursor_url) { api_url('/latest_cursor') }
    let(:cursor_zero_url) { api_url('?cursor=0&exclude_folders=false') }
    let(:nth_cursor_url) { api_url('?cursor=a9vtneydekzye7uwfumdd4iu3&exclude_folders=false') }

    before do
      stub_request(:post, latest_cursor_url).with(basic_auth: [access_token]).
        to_return(:status => 200, :body => File.read('spec/fixtures/latest_cursor.txt'), :headers => {})
      stub_request(:get, cursor_zero_url).with(basic_auth: [access_token]).
        to_return(:status => 200, :body => File.read('spec/fixtures/first_cursor.txt'), :headers => {'Content-Type' => 'application/json'})
      stub_request(:get, nth_cursor_url).with(basic_auth: [access_token]).
        to_return(:status => 200, :body => File.read('spec/fixtures/second_cursor.txt'), :headers => {})
    end

    it 'should get the latest cursor' do
      cursor = inbox.latest_cursor
      expect(cursor).to eq('cx7ln1akyj2qgdu6o5d5bakuw')
    end

    it 'returns an external Enumerator when no block is given' do
      expect(inbox.deltas(nth_cursor)).to be_a(Enumerator)
      expect(inbox.deltas(nth_cursor).map { |e,o| [e, o.id]}).to contain_exactly(
        ['create', 'c7mllq7iag2ivlp6fxf7dhg9i'], ['delete', 'db0isjjvqez51vdjeq5lx37dk'])
    end

    it 'should continuously query the delta sync API' do
      count = 0
      inbox.deltas(timestamp=0) do |event, object|
        expect(object.cursor).to_not be_nil
        if event == 'create' or event == 'modify'
          expect(object).to be_a Inbox::Message
        elsif event == 'delete'
          expect(object).to be_a Inbox::Event
        end
        count += 1
      end

      expect(a_request(:get, cursor_zero_url)).to have_been_made.once
      expect(a_request(:get, nth_cursor_url)).to have_been_made.once
      expect(count).to eq(3)
    end

    it 'should be able to exclude object types from the deltas' do
      cursor = inbox.latest_cursor

      stub_request(:get, api_url("/streaming?cursor=#{cursor}&exclude_folders=false&exclude_types=thread")).
        to_return(:status => 200, :body => File.read('spec/fixtures/delta_stream.txt'), :headers => {'Content-Type' => 'application/json'})

      inbox.delta_stream(cursor, {:exclude_types => [Nylas::Thread]}) do |event, object|
        break
      end
    end

    it 'should be able to include only certain object types in the deltas' do
      cursor = inbox.latest_cursor

      stub_request(:get, api_url("/streaming?cursor=#{cursor}&exclude_folders=false&include_types=thread")).
        to_return(:status => 200, :body => File.read('spec/fixtures/delta_stream.txt'), :headers => {'Content-Type' => 'application/json'})

      inbox.delta_stream(cursor, {:exclude_types => [], :include_types => [Nylas::Thread]}) do |event, object|
        break
      end
    end

    it 'should raise an error if both include and exclude parameters are passed' do
      cursor = inbox.latest_cursor

      expect {
        inbox.delta_stream(cursor, {:include_types => [Nylas::Thread], :exclude_types => [Nylas::Thread]}) do |event, object|
          break
        end
      }.to raise_error(RuntimeError)
    end
  end

  describe 'Delta sync streaming API wrapper' do
    before do
      stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/streaming?cursor=0&exclude_folders=false").
         to_return(:status => 200, :body => File.read('spec/fixtures/delta_stream.txt'), :headers => {'Content-Type' => 'application/json'})
    end

    it 'should continuously query the delta sync API' do
      count = 0
      inbox.delta_stream(0) do |event, object|

        expect(object.cursor).to_not be_nil
        if event == 'create' or event == 'modify'
          expect(object).to be_a Inbox::Message
        elsif event == 'delete'
          expect(object).to be_a Inbox::Event
        end
      end

      expect(count).to eq(3)
    end
  end

  describe 'Delta sync bogus requests' do
    before do
      stub_request(:get, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta/streaming?cursor=0&exclude_folders=false").
        to_return(:status => 200, :body => File.read('spec/fixtures/bogus_stream.txt'), :headers => {'Content-Type' => 'application/json'})
      stub_request(:get, "https://api.nylas.com/delta?cursor=0&exclude_folders=false").
         with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Basic VVhYTU9DSlctQktTTFBDRkktVVFBUUZXTE86', 'User-Agent'=>'Nylas Ruby SDK 2.0.1 - 2.3.1', 'X-Inbox-Api-Wrapper'=>'ruby'}).
        to_return(:status => 200, :body => File.read('spec/fixtures/bogus_second.txt'), :headers => {'Content-Type' => 'application/json'})

    end

    it 'delta sync should skip bogus requests' do
      count = 0
      inbox.deltas(timestamp=0, []) do |event, object|
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

    it 'delta stream should skip bogus requests' do
      count = 0
      inbox.delta_stream(0) do |event, object|
        expect(object.cursor).to_not be_nil
        if event == 'create' or event == 'modify'
          expect(object).to be_a Inbox::Message
        elsif event == 'delete'
          expect(object).to be_a Inbox::Event
          break
        end
      end

      expect(count).to eq(1)
    end
  end
end
