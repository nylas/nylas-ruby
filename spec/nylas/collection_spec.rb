# frozen_string_literal: true

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
    # Check and return the number of collection results on a single page, filtered by the offset,
    # limit, and where params.
    it "Returns an enumerable for a single page of results, filtered by `offset` and `limit` and `where`" do
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a

      expect(results.count).to be 1
    end

    # Allow the API to get and use a block. (Is this all that this does?)
    it "allows you to use a block directly" do
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a
      how_many = 0
      results.each do
        how_many += 1
      end

      expect(how_many).to be 1
    end
  end

  # Find a set of collection objects, filtered by the limit and where params.
  describe "#find_each" do
    it "iterates over every page filtered based on `limit` and `where`" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return(Array.new(100) { example_instance_hash })

      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 100 },
          headers: {}
        ).and_return(Array.new(50) { example_instance_hash })

      expect(collection.find_each.to_a.size).to be 150
    end
  end

  # Find collection objects.
  describe "#find" do
    # Find and retrieve a single collection object without filtering on the where param.
    it "retrieves a single object, without filtering based upon `where` clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      ).and_return(example_instance_hash)

      instance = collection.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
    end

    # Find and retrieve a single collection object, filtering on the view param.
    it "retrieves with `view` argument in query if clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).and_return(example_instance_hash)

      instance = collection.expanded.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: { view: "expanded" },
        headers: {}
      )
    end

    # Find and retrieve a single collection object without filtering on the view param.
    it "retrieves without `view` argument in query if not clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).and_return(example_instance_hash)

      instance = collection.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      )
    end

    # Allow the api param to be sent to a collection's related attributes.
    it "allows `api` to be sent to the related attributes" do
      collection = described_class.new(model: FullModel, api: api)
      expected_response = example_instance_hash.merge(
        files: [
          {
            id: "file-id"
          }
        ]
      )
      allow(api).to receive(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      ).and_return(expected_response)

      instance = collection.find(1234)

      expect(instance.files.first.api).to eq(api)
    end
  end

  # Generate and throw a "not implemented" error when the model is not searchable.
  describe "#where" do
    it "raises a NotImplementedError stating the model is not searchable when the model is not searchable" do
      collection = described_class.new(model: NonFilterableModel, api: api)
      expect { collection.where(id: "1234") }.to raise_error(Nylas::ModelNotFilterableError)
    end
  end

  # Send collection data to an endpoint using POST. If the model cannot be created, a "not implemented"
  # error is generated and thrown.
  describe "#create" do
    it "sends the data to the appropriate endpoint using a post"
    it "Raises a not implemented error if the model is not creatable" do
      collection = described_class.new(model: NotCreatableModel, api: api)
      expect { collection.create(string: "1234") }.to raise_error(Nylas::ModelNotCreatableError)
    end
  end

  # Count the number of objects in a collection.
  describe "#count" do
    # Return the number of objects in a collection.
    it "returns collection count" do
      FullModel.countable = true
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0, view: "count" },
          headers: {}
        ).and_return(count: 1)

      expect(collection.count).to be 1
    end

    # Return the number of objects in a collection, filtered by the where param.
    it "returns collection count filtered by `where`" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: Nylas::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { id: "1234", limit: 100, offset: 0, view: "count" },
          headers: {}
        ).and_return(count: 1)

      expect(collection.where(id: "1234").count).to be 1
    end

    # If a collection that cannot be counted is found, the collection count is still returned.
    describe "models that are not countable" do
      it "still returns collection count" do
        FullModel.countable = false
        collection = described_class.new(model: FullModel, api: api)
        allow(api).to receive(:execute)
          .with(
            auth_method: Nylas::HttpClient::AuthMethod::BEARER,
            method: :get,
            path: "/collection",
            query: { limit: 100, offset: 0 },
            headers: {}
          ).and_return([{ id: "abc123" }])

        expect(collection.count).to be 1
      end
    end
  end

  # Set and generate HTTP errors.
  describe "HTTP errors" do
    http_codes_errors = {
      400 => Nylas::InvalidRequest,
      401 => Nylas::UnauthorizedRequest,
      402 => Nylas::MessageRejected,
      403 => Nylas::AccessDenied,
      404 => Nylas::ResourceNotFound,
      405 => Nylas::MethodNotAllowed,
      410 => Nylas::ResourceRemoved,
      418 => Nylas::TeapotError,
      422 => Nylas::MailProviderError,
      429 => Nylas::SendingQuotaExceeded,
      500 => Nylas::InternalError,
      501 => Nylas::EndpointNotYetImplemented,
      502 => Nylas::BadGateway,
      503 => Nylas::ServiceUnavailable,
      504 => Nylas::RequestTimedOut
    }

    http_codes_errors.each do |code, error|
      # Generate and throw an error based on the error type and error code.
      it "raises error if API returns #{error} with #{code}" do
        api = Nylas::API.new
        model = instance_double("Model")
        allow(model).to receive(:searchable?).and_return(true)
        allow(model).to receive(:resources_path)
        allow(model).to receive(:auth_method)
        collection = described_class.new(model: model, api: api)
        stub_request(:get, "https://api.nylas.com/search?limit=100&offset=0&q=%7B%7D")
          .to_return(status: code, body: {}.to_json)

        expect do
          collection.search({}).last
        end.to raise_error(error)
      end
    end
  end
end
