require 'spec_helper'

# This spec is the only one that should have any webmock stuff going on, everything else should use the
# FakeAPI to see what requests were made and what they included.
describe Nylas::API do
  describe "#current_account" do
    it "retrieves the account for the current OAuth Access Token"

    it "raises an exception if there is not an access token set"
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
