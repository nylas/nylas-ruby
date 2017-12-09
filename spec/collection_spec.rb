require "spec_helper"

describe Nylas::Collection do
  def example_instance_json
    '{ "id": "1234" }'
  end

  def example_instance_hash
    JSON.parse(example_instance_json, symbolize_names: true)
  end

  let(:api) { FakeAPI.new }

  describe "#each" do
    it "Returns an enumerable for a single page of results, filtered by `offset` and `limit` and `where`" do
      allow(api).to receive(:execute).with(method: :get, path: "/collection", query: { limit: 100, offset: 0 }).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a

      expect(results.count).to be 1
    end

    it "allows you to use a block directly" do
      allow(api).to receive(:execute).with(method: :get, path: "/collection", query: { limit: 100, offset: 0 }).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a
      how_many = 0
      results.each do
        how_many += 1
      end

      expect(how_many).to be 1
    end
  end

  describe "#find_each" do
    it "iterates over every page filtered based on `limit` and `where`" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).with(method: :get, path: "/collection",
                                           query: { limit: 100, offset: 0 })
                                     .and_return(100.times.map { example_instance_hash })

      allow(api).to receive(:execute).with(method: :get, path: "/collection",
                                           query: { limit: 100, offset: 100 })
                                     .and_return(50.times.map { example_instance_hash })

      expect(collection.find_each.to_a.size).to be 150
    end
  end

  describe "#find" do
    it "retrieves a single object, without filtering based upon `where` clauses earlier in the chain" do
      collection = described_class.new(model: ReadOnlyModel, api: api)
      allow(api).to receive(:execute).with(method: :get, path: "/read_only_collection/1234").and_return(example_instance_hash)

      instance = collection.find(1234)

      expect(instance.id).to eql "1234"
    end
  end

  describe "#where" do
    it "raises a NotImplementedError stating the model is not searchable when the model is not searchable" do
      collection = described_class.new(model: NonSearchableModel, api: api)
      expect { collection.where(id: "1234") }.to raise_error(NotImplementedError,
                                                             "#{NonSearchableModel} does not support search")
    end
  end

  describe "#create" do
    it "sends the data to the appropriate endpoint using a post"
    it "Raises a not implemented error if the model is read only" do
      collection = described_class.new(model: ReadOnlyModel, api: api)
      expect { collection.create(id: "1234") }.to raise_error(NotImplementedError,
                                                              "#{ReadOnlyModel} is read only")
    end
  end
end
