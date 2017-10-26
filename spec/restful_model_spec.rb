
describe 'RestfulModel' do
  before (:each) do
    @api = Nylas::API.new('app_id', 'app_secret', 'key')
  end

  describe "#as_json" do
    it "should return a hash with the parameter properties" do
      r = Nylas::RestfulModel.new(@api)
      r.id = '1'
      r.account_id = '123';
      r.created_at = Time.new
      expect(r.as_json).to eq({"id" => "1", "account_id" => "123", "created_at" => r.created_at, "cursor" => nil})
    end

    it "should ignore arbitrary setters" do
      model_subclass = Class.new(Nylas::RestfulModel) do
        def foo=(bar); end
      end
      r = model_subclass.new(@api)
      r.id = '1'
      r.account_id = '123';
      r.created_at = Time.new
      expect(r.as_json).to eq({"id" => "1", "account_id" => "123", "created_at" => r.created_at, "cursor" => nil})
    end
  end

  describe "#inflate" do
    it "should set the values provided in the hash on the instance" do
      now = Time.new
      r = Nylas::RestfulModel.new(@api)
      r.inflate({"id" => "1", "account_id" => "123", "created_at" => now})

      expect(r.id).to eq('1')
      expect(r.account_id).to eq('123')
      expect(r.created_at).to eq(now)
    end

    it "should ignore arbitrary json values" do
      model_subclass = Class.new(Nylas::RestfulModel) do
        attr_accessor :foo
      end

      r = model_subclass.new(@api)
      r.inflate({"foo" => "bar"})
      expect(r.foo).to be_nil
    end

    it "should issue a DELETE when calling delete" do
      url = 'http://localhost:5555/messages/1'
      message_url = stub_request(:delete, url)
      r = Nylas::RestfulModel.new(@api)
      allow(r).to receive_messages(:url => url)

      r.destroy
      assert_requested :delete, url
    end

    it "should pass parameters as query parameters when calling delete" do
      url = 'http://localhost:5555/events/1'
      stubbed_url = 'http://localhost:5555/events/1?param1&param2=stuff&send_notifications=true'
      message_url = stub_request(:delete, stubbed_url)
      r = Nylas::RestfulModel.new(@api)
      allow(r).to receive_messages(:url => url)

      r.destroy(:send_notifications => true, :param1 => nil, :param2 => 'stuff')
      assert_requested :delete, stubbed_url
    end
  end
end
