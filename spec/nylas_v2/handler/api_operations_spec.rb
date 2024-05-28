# frozen_string_literal: true

require_relative "../../../lib/nylas_v2/handler/api_operations"

class APIOperations
  include NylasV2::ApiOperations::Get
  include NylasV2::ApiOperations::Post
  include NylasV2::ApiOperations::Put
  include NylasV2::ApiOperations::Patch
  include NylasV2::ApiOperations::Delete

  attr_reader :api_key, :api_uri, :timeout

  def initialize(api_key, api_uri, timeout)
    @api_key = api_key
    @api_uri = api_uri
    @timeout = timeout
  end
end

describe NylasV2::ApiOperations do
  let(:api_operations) { APIOperations.new(api_key, api_uri, timeout) }
  let(:mock_response) do
    {
      request_id: "mock_request_id",
      data: {
        id: "mock_id",
        foo: "bar"
      }
    }
  end

  describe NylasV2::ApiOperations::Get do
    describe "#get" do
      it "returns a response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        allow(api_operations).to receive(:execute).with(
          method: :get,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:get, path: path, query_params: query_params)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end

      it "returns a response with default query_params" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :get,
          path: path,
          query: {},
          payload: nil,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:get, path: path)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end
    end

    describe "#get_list" do
      let(:list_response) do
        {
          request_id: "mock_request_id",
          data: [
            {
              id: "mock_id",
              foo: "bar"
            }
          ],
          next_cursor: "mock_cursor"
        }
      end

      it "returns a list response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        allow(api_operations).to receive(:execute).with(
          method: :get,
          path: path,
          query: query_params,
          payload: nil,
          api_key: api_key,
          timeout: timeout
        ).and_return(list_response)

        response = api_operations.send(:get_list, path: path, query_params: query_params)

        expect(response).to eq([list_response[:data], list_response[:request_id],
                                list_response[:next_cursor]])
      end

      it "returns a list response with default query_params" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :get,
          path: path,
          query: {},
          payload: nil,
          api_key: api_key,
          timeout: timeout
        ).and_return(list_response)

        response = api_operations.send(:get_list, path: path)

        expect(response).to eq([list_response[:data], list_response[:request_id],
                                list_response[:next_cursor]])
      end
    end
  end

  describe NylasV2::ApiOperations::Post do
    describe "#post" do
      it "returns a response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        request_body = { foo: "bar" }
        headers = { "Content-Type" => "application/json" }
        allow(api_operations).to receive(:execute).with(
          method: :post,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:post, path: path, query_params: query_params,
                                              request_body: request_body, headers: headers)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end

      it "returns a response with default query_params, request_body, and headers" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :post,
          path: path,
          query: {},
          payload: nil,
          headers: {},
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:post, path: path)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end
    end
  end

  describe NylasV2::ApiOperations::Put do
    describe "#put" do
      it "returns a response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        request_body = { foo: "bar" }
        headers = { "Content-Type" => "application/json" }
        allow(api_operations).to receive(:execute).with(
          method: :put,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:put, path: path, query_params: query_params,
                                             request_body: request_body, headers: headers)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end

      it "returns a response with defaults" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :put,
          path: path,
          query: {},
          payload: nil,
          headers: {},
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:put, path: path)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end
    end
  end

  describe NylasV2::ApiOperations::Patch do
    describe "#patch" do
      it "returns a response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        request_body = { foo: "bar" }
        headers = { "Content-Type" => "application/json" }
        allow(api_operations).to receive(:execute).with(
          method: :patch,
          path: path,
          query: query_params,
          payload: request_body,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:patch, path: path, query_params: query_params,
                                               request_body: request_body, headers: headers)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end

      it "returns a response with defaults" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :patch,
          path: path,
          query: {},
          payload: nil,
          headers: {},
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:patch, path: path)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end
    end
  end

  describe NylasV2::ApiOperations::Delete do
    describe "#delete" do
      it "returns a response" do
        path = "#{api_uri}/path"
        query_params = { foo: "bar" }
        headers = { "Content-Type" => "application/json" }
        allow(api_operations).to receive(:execute).with(
          method: :delete,
          path: path,
          query: query_params,
          payload: nil,
          headers: headers,
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:delete, path: path, query_params: query_params, headers: headers)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end

      it "returns a response with default query_params" do
        path = "#{api_uri}/path"
        allow(api_operations).to receive(:execute).with(
          method: :delete,
          path: path,
          query: {},
          payload: nil,
          headers: {},
          api_key: api_key,
          timeout: timeout
        ).and_return(mock_response)

        response = api_operations.send(:delete, path: path)

        expect(response).to eq([mock_response[:data], mock_response[:request_id]])
      end
    end
  end
end
