require 'event'

describe Inbox::API do
  subject(:inbox) { Inbox::API.new(app_id, app_secret, access_token) }
  let(:nth_cursor) { 'a9vtneydekzye7uwfumdd4iu3' }
  let(:app_id) { 'ABC' }
  let(:app_secret) { '123' }
  let(:access_token) { 'UXXMOCJW-BKSLPCFI-UQAQFWLO' }
  let(:api_url_template) { 'https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/delta' }

  def api_url(resource)
    "#{api_url_template}#{resource}"
  end

  describe 'Delta sync API wrapper' do
    let(:latest_cursor_url) { api_url('/latest_cursor') }
    let(:cursor_zero_url) { api_url('?cursor=0&exclude_folders=false') }
    let(:nth_cursor_url) { api_url('?cursor=a9vtneydekzye7uwfumdd4iu3&exclude_folders=false') }

    before do
      stub_request(:post, latest_cursor_url).
        to_return(:status => 200, :body => File.read('spec/fixtures/latest_cursor.txt'), :headers => {})
      stub_request(:get, cursor_zero_url).
        to_return(:status => 200, :body => File.read('spec/fixtures/first_cursor.txt'), :headers => {'Content-Type' => 'application/json'})
      stub_request(:get, nth_cursor_url).
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
  end

  describe 'Delta sync streaming API wrapper' do
    before do
      stub_request(:get, api_url('/streaming?cursor=0&exclude_folders=false')).
        to_return(:status => 200, :body => File.read('spec/fixtures/delta_stream.txt'), :headers => {'Content-Type' => 'application/json'})
    end

    it 'should continuously query the delta sync API' do
      count = 0
      EM.run do
        inbox.delta_stream(0, []) do |event, object|

          expect(object.cursor).to_not be_nil
          if event == 'create' or event == 'modify'
            expect(object).to be_a Inbox::Message
          elsif event == 'delete'
            expect(object).to be_a Inbox::Event
          end
          count += 1
          EM.stop if count == 3
        end
      end

      expect(count).to eq(3)
    end
  end

  describe 'Delta sync bogus requests' do
    before do
      stub_request(:get, api_url('?cursor=0&exclude_folders=false')).
        to_return(:status => 200, :body => File.read('spec/fixtures/bogus_second.txt'), :headers => {'Content-Type' => 'application/json'})
      stub_request(:get, api_url('/streaming?cursor=0&exclude_folders=false')).
        to_return(:status => 200, :body => File.read('spec/fixtures/bogus_stream.txt'), :headers => {'Content-Type' => 'application/json'})
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
      EventMachine.run do
        inbox.delta_stream(0, []) do |event, object|
          expect(object.cursor).to_not be_nil
          if event == 'create' or event == 'modify'
            expect(object).to be_a Inbox::Message
            count += 1
          elsif event == 'delete'
            expect(object).to be_a Inbox::Event
            EM.stop
          end
        end
      end

      expect(count).to eq(1)
    end
  end
end
