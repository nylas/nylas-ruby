::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RestfulModel' do
  before (:each) do
    @api = Inbox::API.new('app_id', 'app_secret', 'key')
  end

  describe "#as_json" do
    it "should return a hash with the attr_accessor properties" do
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

end