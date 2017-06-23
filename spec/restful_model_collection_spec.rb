describe Nylas::RestfulModelCollection do
  let(:api) { Nylas::API.new(app_id, app_secret, access_token) }
  let(:app_id) { 'ABC' }
  let(:app_secret) { '123' }
  let(:access_token) { 'UXXMOCJW-BKSLPCFI-UQAQFWLO' }

  describe '#each' do
    before do
      stub_request(:get, "https://api.nylas.com/threads?limit=100&offset=0").
        with(basic_auth: [access_token]).
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/threads_reply.txt'),
                  :headers => {'Content-Type' => 'application/json'})
    end

    it 'returns an external Enumerator when no block is given' do
      expect(api.threads.each).to be_a(Enumerator)
      expect(api.threads.each.map {|t| t.id }).to eq(['320yc9ie5rungx75j139dsgao', 'vxz6vx6rm2imw0mow9rc1prk'])
    end

    it 'yields the individual threads when a block is given' do
      thread_ids = []
      api.threads.each { |t| thread_ids << t.id }
      expect(thread_ids).to eq(['320yc9ie5rungx75j139dsgao', 'vxz6vx6rm2imw0mow9rc1prk'])
    end
  end

  describe '#count' do
    it 'should return number of entities' do
      stub_request(:get, "https://api.nylas.com/threads?view=count").
        with(basic_auth: [access_token]).
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/threads_count.txt'),
                  :headers => {'Content-Type' => 'application/json'})

      expect(api.threads.count).to eq(42)
    end

    it 'should raise an error when the API raises an error' do
      stub_request(:get, "https://api.nylas.com/threads?view=count").
        with(basic_auth: [access_token]).
        to_return(:status => 403,
                   :body => '{"message": "Could not verify access credential.",'+
                            '"type": "invalid_request_error"}')

      expect { api.threads.count }.to raise_error(Nylas::AccessDenied)
    end
  end

  describe '#delete' do
    let(:event_id) { 'nylas_event_id' }
    let(:remove_url) { "https://api.nylas.com/events/#{event_id}" }

    before do
      stub_request(:delete, remove_url).to_return(status: 200, body: '')
    end

    it 'sends request to remove event' do
      api.events.delete(event_id)
      expect(a_request(:delete, remove_url)).to have_been_made.once
    end
  end
end
