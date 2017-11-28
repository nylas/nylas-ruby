describe Nylas::API do
  let(:api) { Nylas::API.new('app_id', 'app_secret', 'key') }

  describe '#messages' do
    context 'when expanded param is true' do
      it 'requests expanded messages' do
        stub_request(:get, 'https://api.nylas.com/messages?limit=100&offset=0&view=expanded')
          .to_return(status: 200, body: '[]', headers: {})

        api.messages(expanded: true).all
      end
    end

    context 'when expanded param is false' do
      it 'requests messages' do
        stub_request(:get, 'https://api.nylas.com/messages?limit=100&offset=0')
          .to_return(status: 200, body: '[]', headers: {})

        api.messages.all
      end
    end
  end

  describe 'default headers' do
    let!(:request) do
      stub_request(:post, 'https://api.nylas.com/oauth/token')
        .with(headers: {
                'X-Nylas-API-Wrapper' => 'ruby',
                'User-Agent' => "Nylas Ruby SDK #{Nylas::VERSION} - #{RUBY_VERSION}"
              })
        .to_return(status: 200, body: '{"access_token": "456"}', headers: {})
    end

    it 'adds default headers' do
      api.token_for_code('123')
      expect(request).to have_been_made
    end
  end
end
