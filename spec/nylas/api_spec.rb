# frozen_string_literal: true

require "spec_helper"

# This spec is the only one that should have any webmock stuff going on, everything else should use
#   the FakeAPI to see what requests were made and what they included.
describe Nylas::API do
  describe "#exchange_code_for_token" do
    it "retrieves oauth token with code" do
      client = Nylas::HttpClient.new(app_id: "fake-app", app_secret: "fake-secret")
      data = {
        "client_id" => "fake-app",
        "client_secret" => "fake-secret",
        "grant_type" => "authorization_code",
        "code" => "fake-code"
      }
      response = {
        account_id: "account-id",
        email_address: "fake@email.com",
        provider: "yahoo",
        token_type: "barer",
        access_token: "fake-token"
      }
      allow(client).to receive(:execute).with(method: :post, path: "/oauth/token", payload: data)
                                        .and_return(response)
      api = described_class.new(client: client)
      expect(api.exchange_code_for_token("fake-code")).to eql("fake-token")
    end

    it "retrieves full response from the server" do
      client = Nylas::HttpClient.new(app_id: "fake-app", app_secret: "fake-secret")
      data = {
        "client_id" => "fake-app",
        "client_secret" => "fake-secret",
        "grant_type" => "authorization_code",
        "code" => "fake-code"
      }
      response = {
        account_id: "account-id",
        email_address: "fake@email.com",
        provider: "yahoo",
        token_type: "barer",
        access_token: "fake-token"
      }
      allow(client).to receive(:execute).with(method: :post, path: "/oauth/token", payload: data)
                                        .and_return(response)
      api = described_class.new(client: client)
      expect(api.exchange_code_for_token("fake-code", return_full_response: true)).to eql(response)
    end
  end

  describe "#authentication_url" do
    context "with required parameters" do
      it "returns url for hosted_authentication" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: "http://example.com",
          scopes: %w[email calendar],
          login_hint: "email@example.com",
          state: "some-state"
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri=http%3A%2F%2Fexample.com"\
        "&response_type=code"\
        "&login_hint=email%40example.com"\
        "&state=some-state"\
        "&scopes=email%2Ccalendar"
        expect(hosted_auth_url).to eq expected_url
      end
    end

    context "with required and optional parameters" do
      it "returns url for hosted_authentication with optional parameters" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: "http://example.com",
          scopes: %w[email calendar],
          login_hint: "email@example.com",
          state: "some-state",
          provider: "gmail",
          redirect_on_error: true,
          disable_provider_selection: true
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri=http%3A%2F%2Fexample.com"\
        "&response_type=code"\
        "&login_hint=email%40example.com"\
        "&state=some-state"\
        "&scopes=email%2Ccalendar"\
        "&provider=gmail"\
        "&redirect_on_error=true"\
        "&disable_provider_selection=true"
        expect(hosted_auth_url).to eq expected_url
      end
    end

    context "when required parameter are missing" do
      it "throws argument error if redirect uri is mising" do
        api = described_class.new(app_id: "2454354")

        expect do
          api.authentication_url(scopes: ["email"])
        end.to raise_error(ArgumentError, /redirect_uri/)
      end

      it "throws argument error if scopes is mising" do
        api = described_class.new(app_id: "2454354")

        expect do
          api.authentication_url(redirect_uri: "http://example.com")
        end.to raise_error(ArgumentError, /scopes/)
      end

      it "generates wrong url if scopes and redirect_uri is nil" do
        api = described_class.new(app_id: "2454354")

        hosted_auth_url = api.authentication_url(
          redirect_uri: nil,
          scopes: nil
        )

        expected_url = "https://api.nylas.com/oauth/authorize"\
        "?client_id=2454354"\
        "&redirect_uri"\
        "&response_type=code"\
        "&login_hint"
        expect(hosted_auth_url).to eq(expected_url)
      end
    end
  end

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

  describe "#free_busy" do
    it "returns `Nylas::FreeBusyCollection` for free busy details" do
      emails = ["test@example.com", "anothertest@example.com"]
      start_time = 1_609_439_400
      end_time = 1_640_975_400
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real",
        access_token: "seriously-unreal"
      )
      api = described_class.new(client: client)
      free_busy_response = [
        {
          object: "free_busy",
          email: "test@example.com",
          time_slots: [
            {
              object: "time_slot",
              status: "busy",
              start_time: 1_609_439_400,
              end_time: 1_640_975_400
            }
          ]
        }
      ]
      allow(client).to receive(:execute).with(
        method: :post,
        path: "/calendars/free-busy",
        payload: {
          emails: emails,
          start_time: start_time,
          end_time: end_time
        }.to_json
      ).and_return(free_busy_response)

      result = api.free_busy(
        emails: emails,
        start_time: Time.at(start_time),
        end_time: Time.at(end_time)
      )

      expect(result).to be_a(Nylas::FreeBusyCollection)
      free_busy = result.last
      expect(free_busy.object).to eq("free_busy")
      expect(free_busy.email).to eq("test@example.com")
      time_slot = free_busy.time_slots.last
      expect(time_slot.object).to eq("time_slot")
      expect(time_slot.status).to eq("busy")
      expect(time_slot.start_time.to_i).to eq(start_time)
      expect(time_slot.end_time.to_i).to eq(end_time)
    end
  end

  describe "application details" do
    it "gets the application details" do
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real"
      )
      api = described_class.new(client: client)
      application_details_response = {
        application_name: "My New App Name",
        icon_url: "http://localhost/icon.png",
        redirect_uris: %w[http://localhost/callback]
      }
      stub_request(:get, "https://api.nylas.com/a/not-real")
        .to_return(
          status: 200,
          body: application_details_response.to_json,
          headers: { "content-type" => "application/json" }
        )

      app_details = api.application_details

      expect(app_details).to be_a(Nylas::ApplicationDetail)
      expect(app_details.application_name).to eq("My New App Name")
      expect(app_details.icon_url).to eq("http://localhost/icon.png")
      expect(app_details.redirect_uris).to eq(%w[http://localhost/callback])
    end

    it "updates the application details" do
      application_details_response = {
        application_name: "Updated App Name",
        icon_url: "http://localhost/updated_icon.png",
        redirect_uris: %w[http://localhost/callback http://localhost/updated]
      }
      app_details = Nylas::ApplicationDetail.new
      app_details.application_name = "Updated App Name"
      app_details.icon_url = "http://localhost/updated_icon.png"
      app_details.redirect_uris = %w[http://localhost/callback http://localhost/updated]
      client = Nylas::HttpClient.new(
        app_id: "not-real",
        app_secret: "also-not-real"
      )
      api = described_class.new(client: client)
      stub_request(:put, "https://api.nylas.com/a/not-real")
        .to_return(
          status: 200,
          body: application_details_response.to_json,
          headers: { "content-type" => "application/json" }
        )

      updated_app_details = api.update_application_details(app_details)

      expect(updated_app_details).to be_a(Nylas::ApplicationDetail)
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
