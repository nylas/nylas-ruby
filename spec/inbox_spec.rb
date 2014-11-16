::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Inbox' do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
  end

  describe "initialize" do
    it "should add the 'before_execution_proc' to the RestClient to set the header" do
      expect(::RestClient.before_execution_procs.empty?).to eq(true)
      @inbox = Inbox::API.new(@app_id, @app_secret)
      expect(::RestClient.before_execution_procs.empty?).to eq(false)
    end

    it "should not do this multiple times if multiple copies of the Inbox::API are initialized" do
      @inbox = Inbox::API.new(@app_id, @app_secret)
      @inbox = Inbox::API.new(@app_id, @app_secret)
      expect(::RestClient.before_execution_procs.count).to eq(1)
    end
  end
  describe "#url_for_path" do
    before (:each) do
      @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
    end

    it "should return the url for a provided path" do
      expect(@inbox.url_for_path('/wobble')).to eq("https://#{@inbox.access_token}:@api.inboxapp.com/wobble")
    end

    it "should return an error if you have not provided an auth token" do
      @inbox = Inbox::API.new(@app_id, @app_secret)
      expect {
        @inbox.url_for_path('/wobble')
      }.to raise_error(Inbox::NoAuthToken)
    end
  end

  describe "#url_for_authentication" do
    before (:each) do
      @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
    end

    it "should return the OAuth authorize endpoint with the provided redirect_uri" do
      url = @inbox.url_for_authentication('http://redirect.uri')
      expect(url).to eq("https://www.inboxapp.com/oauth/authorize?client_id=#{@app_id}&trial=false&response_type=code&scope=email&login_hint=&redirect_uri=http://redirect.uri")
    end

    it "should include the login_hint if one is provided" do
      url = @inbox.url_for_authentication('http://redirect.uri', 'ben@inboxapp.com')
      expect(url).to eq("https://www.inboxapp.com/oauth/authorize?client_id=#{@app_id}&trial=false&response_type=code&scope=email&login_hint=ben@inboxapp.com&redirect_uri=http://redirect.uri")
    end

    it "should use trial=true if the trial flag is passed" do
      url = @inbox.url_for_authentication('http://redirect.uri', 'ben@inboxapp.com', {trial: true})
      expect(url).to eq("https://www.inboxapp.com/oauth/authorize?client_id=#{@app_id}&trial=true&response_type=code&scope=email&login_hint=ben@inboxapp.com&redirect_uri=http://redirect.uri")
    end
  end

  describe "#self.interpret_response" do
    before (:each) do
      @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
      @result = double('result')
      allow(@result).to receive(:code).and_return(200)
    end

    context "when an expected_class is provided" do
      context "when the server responds with a 200 but unknown, invalid body" do
        it "should raise an UnexpectedResponse" do
          expect {
            Inbox.interpret_response(@result, "I AM NOT JSON", {:expected_class => Array})
          }.to raise_error(Inbox::UnexpectedResponse)
        end
      end

      context "when the server responds with JSON that does not represent an array" do
        it "should raise an UnexpectedResponse" do
          allow(@result).to receive(:code).and_return(500)
          expect {
            Inbox.interpret_response(@result, "{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", {:expected_class => Array})
          }.to raise_error(Inbox::UnexpectedResponse)
        end
      end
    end

    context "when the server responds with a 403" do
      it "should raise AccessDenied" do
        allow(@result).to receive(:code).and_return(403)
        expect {
          Inbox.interpret_response(@result, '')
        }.to raise_error(Inbox::AccessDenied)
      end
    end

    context "when the server responds with a 404" do
      it "should raise ResourceNotFound" do
        allow(@result).to receive(:code).and_return(404)
        expect {
          Inbox.interpret_response(@result, '')
        }.to raise_error(Inbox::ResourceNotFound)
      end
    end

    context "when the server responds with another status code" do
      it "should raise an UnexpectedResponse" do
        allow(@result).to receive(:code).and_return(500)
        expect {
          Inbox.interpret_response(@result, '')
        }.to raise_error(Inbox::UnexpectedResponse)
      end
    end

  end

end
