# frozen_string_literal: true

require "spec_helper"

describe Nylas::Scheduler do
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        id: 123,
        app_client_id: "test-client-id",
        app_organization_id: 0,
        config: {
          timezone: "America/Los_Angeles"
        },
        edit_token: "token",
        name: "Test",
        slug: "test-slug",
        created_at: "2021-06-24",
        modified_at: "2021-06-24"
      }

      scheduler = described_class.from_json(JSON.dump(data), api: api)

      expect(scheduler.id).to be 123
      expect(scheduler.app_client_id).to eql "test-client-id"
      expect(scheduler.app_organization_id).to be 0
      expect(scheduler.config).to be_a(Nylas::SchedulerConfig)
      expect(scheduler.config.timezone).to eql "America/Los_Angeles"
      expect(scheduler.edit_token).to eql "token"
      expect(scheduler.name).to eql "Test"
      expect(scheduler.slug).to eql "test-slug"
      expect(scheduler.created_at).to eql Date.parse("2021-06-24")
      expect(scheduler.modified_at).to eql Date.parse("2021-06-24")
    end

    it "uses 'api.schedule.nylas.com' endpoint" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)

      scheduler = api.scheduler

      expect(scheduler.api.client.api_server).to eql "https://api.schedule.nylas.com"
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
        app_client_id: "test-client-id",
        app_organization_id: 0,
        config: {
          timezone: "America/Los_Angeles"
        },
        edit_token: "token",
        name: "Test",
        slug: "test-slug",
        created_at: "2021-06-24T21:28:09Z",
        modified_at: "2021-06-24T21:28:09Z"
      }
      scheduler = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      scheduler.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :post,
        path: "/manage/pages",
        payload: JSON.dump(
          app_client_id: "test-client-id",
          app_organization_id: 0,
          config: {
            timezone: "America/Los_Angeles"
          },
          edit_token: "token",
          name: "Test",
          slug: "test-slug",
          created_at: "2021-06-24",
          modified_at: "2021-06-24"
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
        id: 123,
        app_client_id: "test-client-id",
        app_organization_id: 0,
        config: {
          timezone: "America/Los_Angeles"
        },
        edit_token: "token",
        name: "Test",
        slug: "test-slug",
        created_at: "2021-06-24T21:28:09Z",
        modified_at: "2021-06-24T21:28:09Z"
      }
      scheduler = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      scheduler.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/manage/pages/123",
        payload: JSON.dump(
          app_client_id: "test-client-id",
          app_organization_id: 0,
          config: {
            timezone: "America/Los_Angeles"
          },
          edit_token: "token",
          name: "Test",
          slug: "test-slug",
          created_at: "2021-06-24",
          modified_at: "2021-06-24"
        ),
        query: {}
      )
    end
  end

  describe "get available calendars" do
    it "makes a request with an ID present" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        id: 123
      }
      scheduler = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      scheduler.get_available_calendars

      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/manage/pages/123/calendars"
      )
    end

    it "throws an error if no ID present" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      scheduler = described_class.from_json(JSON.dump({}), api: api)
      allow(api).to receive(:execute).and_return({})

      expect do
        scheduler.get_available_calendars
      end.to raise_error(ArgumentError)
    end
  end

  describe "upload image" do
    it "makes a request with an ID present" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      data = {
        id: 123
      }
      scheduler = described_class.from_json(JSON.dump(data), api: api)
      allow(api).to receive(:execute).and_return({})

      scheduler.upload_image(content_type: "image", object_name: "logo.png")

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/manage/pages/123/upload-image",
        payload: JSON.dump(
          contentType: "image",
          objectName: "logo.png"
        )
      )
    end

    it "throws an error if no ID present" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = Nylas::API.new(client: client)
      scheduler = described_class.from_json(JSON.dump({}), api: api)
      allow(api).to receive(:execute).and_return({})

      expect do
        scheduler.upload_image(content_type: "image", object_name: "logo.png")
      end.to raise_error(ArgumentError)
    end
  end
end
