require 'nylas'

describe Nylas::V1::File do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Nylas::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#download" do
    it "requests the raw contents of a file" do
      url = "https://api.nylas.com/files/2/download"
      stub_request(:get, url).with(basic_auth: [@access_token]).
      to_return(:status => 200, :body => "Raw body")

      file = File.new(@inbox, nil)
      file.id = 2
      expect(file.download).to eq('Raw body')
      expect(a_request(:get, url)).to have_been_made.once
    end

    it "raises an error when getting an API error" do
      url = "https://api.nylas.com/files/2/download"
      stub_request(:get, url).with(basic_auth: [@access_token]).
      to_return(:status => 404, :body => '{"message": "Couldn\'t find file fakefile ",' +
                                         '"type": "invalid_request_error"}')

      file = File.new(@inbox, nil)
      file.id = 2
      expect{ file.download }.to raise_error(Nylas::ResourceNotFound)
      expect(a_request(:get, url)).to have_been_made.once
    end
  end
end
