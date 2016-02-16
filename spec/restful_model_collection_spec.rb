describe Nylas::RestfulModelCollection do
  let(:api) { Inbox::API.new(app_id, app_secret, access_token) }
  let(:app_id) { 'ABC' }
  let(:app_secret) { '123' }
  let(:access_token) { 'UXXMOCJW-BKSLPCFI-UQAQFWLO' }

  describe '#each' do
    before do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/threads?limit=100&offset=0").
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
      stub_request(:get, "https://#{access_token}:@api.nylas.com/threads?view=count").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/threads_count.txt'),
                  :headers => {'Content-Type' => 'application/json'})

      expect(api.threads.count).to eq(42)
    end

    it 'should raise an error when the API raises an error' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/threads?view=count").
        to_return(:status => 403)

      expect { api.threads.count }.to raise_error(Inbox::AccessDenied)
    end
  end

  describe '#where' do
    it 'should be able to limit the returned number of entities' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=2").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:limit => 2)
    end

    it 'should be able to offset the returned entities' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?offset=2").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:offset => 2)
    end

    it 'should be able to both limit and offset returned entities' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?offset=3&limit=2").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:limit => 2, :offset => 3)
    end

    it 'should be able to return messages contained in a specific folder' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?in=inbox").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:in => 'inbox')
    end

    it 'should be able to return messages sent to a specific address' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:to => 'someone@nylas.com')
    end
  end

  it 'can execute complex queries combining range and where' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=10&offset=5&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:to => 'someone@nylas.com').range(5, 10)
  end

  it 'can chain each with range to form complex queries' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=10&offset=5").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.range(5, 10).each do |a|
        end
  end

  it 'can chain each with where to form complex queries' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=10&offset=5&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:to => 'someone@nylas.com', :limit => 10, :offset => 5).each do |a|
        end
  end

  it 'can chain first with where, and gives first precedence' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=1&offset=0&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        message = api.messages.where(:to => 'someone@nylas.com', :limit => 10, :offset => 5).first
  end

  it 'can issue multiple filtered requests, each with the correct parameters' do
      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=1&offset=0&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        message = api.messages.where(:to => 'someone@nylas.com', :limit => 10, :offset => 5).first

      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=10&offset=5&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:to => 'someone@nylas.com', :limit => 10, :offset => 5).each do |a|
        end

      stub_request(:get, "https://#{access_token}:@api.nylas.com/messages?limit=10&offset=0&to=someone%40nylas%2ecom").
        to_return(:status => 200,
                  :body => File.read('spec/fixtures/messages_reply_2.txt'),
                  :headers => {'Content-Type' => 'application/json'})

        api.messages.where(:to => 'someone@nylas.com', :limit => 10).each do |a|
        end
  end
end
