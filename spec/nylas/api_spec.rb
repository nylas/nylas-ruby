# frozen_string_literal: true

require "spec_helper"

# This spec is the only one that should have any webmock stuff going on, everything else should use the
# FakeAPI to see what requests were made and what they included.
describe Nylas::API do
  describe "#contact_groups" do
    it "returns Nylas::Collection for contact groups" do
      client = instance_double("Nylas::HttpClient")
      api = described_class.new(client: client)

      result = api.contact_groups

      expect(result).to be_a(Nylas::Collection)
    end
  end

  describe "#current_account" do
    it "retrieves the account for the current OAuth Access Token" do
      client = Nylas::HttpClient.new(app_id: "not-real", app_secret: "also-not-real",
                                     access_token: "seriously-unreal")
      allow(client).to receive(:execute).with(method: :get, path: "/account").and_return(id: 1234)
      api = described_class.new(client: client)
      expect(api.current_account.id).to eql("1234")
    end

    it "raises an exception if there is not an access token set" do
      client = Nylas::HttpClient.new(app_id: "not-real", app_secret: "also-not-real")
      allow(client).to receive(:execute).with(method: :get, path: "/account").and_return(id: 1234)
      api = described_class.new(client: client)
      expect { api.current_account.id }.to raise_error Nylas::NoAuthToken,
                                                       "No access token was provided and the " \
                                                       "current_account method requires one"
    end

    it "sets X-Nylas-Client-Id header" do
      client = Nylas::HttpClient.new(app_id: "not-real", app_secret: "also-not-real")
      expect(client.default_headers).to include("X-Nylas-Client-Id" => "not-real")
    end
  end

  describe "#execute" do
    it "builds the URL based upon the api_server it was initialized with"
    it "adds the nylas headers to the request"
    it "allows you to add more headers"
    it "raises the appropriate exceptions based on the status code it gets back"
    it "includes the passed in query params in the URL"
    it "appropriately sends a string payload as a string"
    it "sends a hash payload as a string of JSON"
    it "yields the response body, request and result to a block and returns the blocks result"
    it "returns the response body if no block is given"
  end
end
