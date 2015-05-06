::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RestfulModelCollection' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @api = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe '#count' do
    it 'should return number of entities' do
      stub_request(:get, "https://#{@access_token}:@api.nylas.com/n/#{@namespace_id}/threads?view=count").to_return(
               :status => 200,
               :body => File.read('spec/fixtures/threads_count.txt'),
               :headers => {"Content-Type" => "application/json"})

      n = Inbox::Namespace.new(@api)
      n.id = @namespace_id
      expect(n.threads.count).to eq(42)
    end

    it 'should raise an error when the API raises an error' do
      stub_request(:get, "https://#{@access_token}:@api.nylas.com/n/#{@namespace_id}/threads?view=count").to_return(
                   :status => 403)

      n = Inbox::Namespace.new(@api)
      n.id = @namespace_id
      expect { n.threads.count }.to raise_error(Inbox::AccessDenied)
    end
  end
end
