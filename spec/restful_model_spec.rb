::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RestfulModel' do
  before (:each) do
    @api = Inbox::API.new('app_id', 'app_secret', 'key')
  end

  describe "#as_json" do
    it "should return a hash with the parameter properties" do
      r = Inbox::RestfulModel.new(@api)
      r.id = '1'
      r.namespace_id = '123';
      r.created_at = Time.new
      expect(r.as_json).to eq({"id" => "1", "namespace_id" => "123", "created_at" => r.created_at})
    end

    it "should ignore arbitrary setters" do
      model_subclass = Class.new(Inbox::RestfulModel) do
        def foo=(bar); end
      end
      r = model_subclass.new(@api)
      r.id = '1'
      r.namespace_id = '123';
      r.created_at = Time.new
      expect(r.as_json).to eq({"id" => "1", "namespace_id" => "123", "created_at" => r.created_at})
    end
  end

  describe "#inflate" do
    it "should set the values provided in the hash on the instance" do
      now = Time.new
      r = Inbox::RestfulModel.new(@api)
      r.inflate({"id" => "1", "namespace_id" => "123", "created_at" => now})

      expect(r.id).to eq('1')
      expect(r.namespace_id).to eq('123')
      expect(r.created_at).to eq(now)
    end

    it "should ignore arbitrary json values" do
      model_subclass = Class.new(Inbox::RestfulModel) do
        attr_accessor :foo
      end

      r = model_subclass.new(@api)
      r.inflate({"foo" => "bar"})
      expect(r.foo).to be_nil
    end

    it "should issue a DELETE when calling delete" do
      url = 'http://localhost:5555/n/1/messages/1'
      message_url = stub_request(:delete, url)
      r = Inbox::RestfulModel.new(@api)
      r.stub(:url) { url }

      r.destroy
      assert_requested :delete, url
    end
  end
end
