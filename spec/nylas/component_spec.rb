# frozen_string_literal: true

describe Nylas::Component do
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        id: "abc-123",
        account_id: "account-123",
        name: "test-component",
        type: "agenda",
        action: 0,
        active: true,
        settings: {},
        allowed_domains: [],
        public_account_id: "account-123",
        public_token_id: "token-123",
        public_application_id: "application-123",
        created_at: "2021-08-24T15:05:48.000Z",
        updated_at: "2021-08-24T15:05:48.000Z"
      }

      component = described_class.from_json(JSON.dump(data), api: api)

      expect(component.id).to eql "abc-123"
      expect(component.account_id).to eql "account-123"
      expect(component.name).to eql "test-component"
      expect(component.type).to eql "agenda"
      expect(component.action).to be 0
      expect(component.active).to be true
      expect(component.settings).to eql({})
      expect(component.allowed_domains).to eql([])
      expect(component.public_account_id).to eql "account-123"
      expect(component.public_token_id).to eql "token-123"
      expect(component.public_application_id).to eql "application-123"
      expect(component.created_at).to eql Date.parse("2021-08-24")
      expect(component.updated_at).to eql Date.parse("2021-08-24")
    end
  end

  describe "saving" do
    it "POST with no ID set" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        account_id: "account-123",
        name: "test-component",
        type: "agenda",
        action: 0,
        active: true,
        settings: { foo: "bar" },
        allowed_domains: ["www.nylas.com"],
        public_account_id: "account-123",
        public_token_id: "token-123",
        public_application_id: "application-123",
        created_at: "2021-08-24T15:05:48.000Z",
        updated_at: "2021-08-24T15:05:48.000Z"
      }
      component = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      component.save

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/component/not-real",
        payload: JSON.dump(
          account_id: "account-123",
          name: "test-component",
          type: "agenda",
          action: 0,
          active: true,
          settings: { foo: "bar" },
          public_account_id: "account-123",
          public_token_id: "token-123",
          allowed_domains: ["www.nylas.com"]
        ),
        query: {}
      )
    end

    it "PUT with ID set" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        id: "abc-123",
        account_id: "account-123",
        name: "test-component",
        type: "agenda",
        action: 0,
        active: true,
        settings: { foo: "bar" },
        allowed_domains: ["www.nylas.com"],
        public_account_id: "account-123",
        public_token_id: "token-123",
        public_application_id: "application-123",
        created_at: "2021-08-24T15:05:48.000Z",
        updated_at: "2021-08-24T15:05:48.000Z"
      }
      scheduler = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      scheduler.save

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/component/not-real/abc-123",
        payload: JSON.dump(
          account_id: "account-123",
          name: "test-component",
          type: "agenda",
          action: 0,
          active: true,
          settings: { foo: "bar" },
          public_account_id: "account-123",
          public_token_id: "token-123",
          allowed_domains: ["www.nylas.com"]
        ),
        query: {}
      )
    end
  end
end
