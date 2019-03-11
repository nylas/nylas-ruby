require "spec_helper"

describe Nylas::NativeAuthentication do
  describe "#authenticate" do
    it "sets all scopes by default" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize", payload: be_json_including("scopes" => "email,calendar,contacts")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token", payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = Nylas::API.new(client: client)

      expect(
        api.authenticate(
          name: 'fake',
          email_address: 'fake@example.com',
          provider: :gmail,
          settings: {}
        )
      ).to eql("fake-token")
    end

    it "allows arrays of one scope" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize", payload: be_json_including("scopes" => "email")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token", payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = Nylas::API.new(client: client)

      expect(
        api.authenticate(
          name: 'fake',
          email_address: 'fake@example.com',
          provider: :gmail,
          settings: {},
          scopes: ["email"]
        )
      ).to eql("fake-token")
    end

    it "allows arrays of two scopes" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize", payload: be_json_including("scopes" => "email,contacts")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token", payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = Nylas::API.new(client: client)

      expect(
        api.authenticate(
          name: 'fake',
          email_address: 'fake@example.com',
          provider: :gmail,
          settings: {},
          scopes: ["email", "contacts"]
        )
      ).to eql("fake-token")
    end

    it "allows string scopes" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/authorize", payload: be_json_including("scopes" => "calendar")
      ).and_return(code: 1234)
      expect(client).to receive(:execute).with(
        method: :post, path: "/connect/token", payload: be_json_including("code" => 1234)
      ).and_return(access_token: "fake-token")
      api = Nylas::API.new(client: client)

      expect(
        api.authenticate(
          name: 'fake',
          email_address: 'fake@example.com',
          provider: :gmail,
          settings: {},
          scopes: "calendar"
        )
      ).to eql("fake-token")
    end
  end
end
