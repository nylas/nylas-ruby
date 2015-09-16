::ENV['RACK_ENV'] = 'test'

describe 'RestfulModelCollection' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @api = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe '#count' do
    it 'should return number of entities' do
      stub_request(:get, "https://#{@access_token}:@api.nylas.com/threads?view=count").to_return(
               :status => 200,
               :body => File.read('spec/fixtures/threads_count.txt'),
               :headers => {"Content-Type" => "application/json"})

      expect(@api.threads.count).to eq(42)
    end

    it 'should raise an error when the API raises an error' do
      stub_request(:get, "https://#{@access_token}:@api.nylas.com/threads?view=count").to_return(
                   :status => 403)

      expect { @api.threads.count }.to raise_error(Inbox::AccessDenied)
    end
  end
end
