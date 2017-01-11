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
end
