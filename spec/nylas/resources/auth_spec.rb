# frozen_string_literal: true

describe Nylas::Auth do
  let(:auth) { described_class.new(client) }

  describe "OAuth 2.0 URL Building" do
    describe "#url_for_oauth2" do
      it "builds the URL for authenticating users to your application with OAuth 2.0" do
        config = {
          "client_id": "abc-123",
          "redirect_uri": "https://example.com/oauth/callback",
          "scope": ["email.read_only", "calendar", "contacts"],
          "login_hint": "test@gmail.com",
          "provider": "google",
          "prompt": "select_provider,detect",
          "state": "abc-123-state"
        }
        url = "https://test.api.nylas.com/v3/connect/auth?client_id=abc-123&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fcallback&access_type=online&response_type=code&provider=google&prompt=select_provider%2Cdetect&state=abc-123-state&scope=email.read_only%20calendar%20contacts&login_hint=test%40gmail.com"

        expect(auth.url_for_oauth2(config)).to eq(url)
      end
    end

    describe "#url_for_admin_consent" do
      it "builds the URL for admin consent" do
        config = {
          "credential_id": "cred-123",
          "client_id": "abc-123",
          "redirect_uri": "https://example.com/oauth/callback",
          "scope": ["email.read_only", "calendar", "contacts"],
          "login_hint": "test@gmail.com",
          "prompt": "select_provider,detect",
          "state": "abc-123-state"
        }
        url = "https://test.api.nylas.com/v3/connect/auth?client_id=abc-123&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fcallback&access_type=online&response_type=adminconsent&prompt=select_provider%2Cdetect&state=abc-123-state&scope=email.read_only%20calendar%20contacts&login_hint=test%40gmail.com&provider=microsoft&credential_id=cred-123"

        expect(auth.url_for_admin_consent(config)).to eq(url)
      end
    end

    describe "#url_for_oauth2_pkce" do
      it "builds the URL for authenticating users to your application with OAuth 2.0 PKCE" do
        config = {
          "client_id": "abc-123",
          "redirect_uri": "https://example.com/oauth/callback",
          "scope": ["email.read_only", "calendar", "contacts"],
          "login_hint": "test@gmail.com",
          "provider": "google",
          "prompt": "select_provider,detect",
          "state": "abc-123-state"
        }
        allow(SecureRandom).to receive(:uuid).and_return("nylas")

        result = auth.url_for_oauth2_pkce(config)

        expect(result[:secret]).to eq("nylas")
        expect(result[:secret_hash]).to eq("ZTk2YmY2Njg2YTNjMzUxMGU5ZTkyN2RiNzA2OWNiMWNiYTliOTliMDIyZjQ5NDgzYTZjZTMyNzA4MDllNjhhMg")
        expect(result[:url]).to eq("https://test.api.nylas.com/v3/connect/auth?client_id=abc-123&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fcallback&access_type=online&response_type=code&provider=google&prompt=select_provider%2Cdetect&state=abc-123-state&scope=email.read_only%20calendar%20contacts&login_hint=test%40gmail.com&code_challenge_method=s256&code_challenge=ZTk2YmY2Njg2YTNjMzUxMGU5ZTkyN2RiNzA2OWNiMWNiYTliOTliMDIyZjQ5NDgzYTZjZTMyNzA4MDllNjhhMg")
      end
    end
  end

  describe "Exchanging tokens" do
    describe "#exchange_code_for_token" do
      it "exchanges the authorization code for an access token" do
        config = {
          "client_id": "abc-123",
          "client_secret": "secret",
          "code": "code",
          "redirect_uri": "https://example.com/oauth/callback"
        }

        allow(auth).to receive(:execute).with(
          method: :post,
          path: "#{api_uri}/v3/connect/token",
          query: {},
          payload: {
            client_id: "abc-123",
            client_secret: "secret",
            code: "code",
            redirect_uri: "https://example.com/oauth/callback",
            grant_type: "authorization_code"
          },
          headers: {},
          api_key: api_key,
          timeout: timeout
        )

        auth.exchange_code_for_token(config)
      end

      it "exchanges the authorization code for an access token using the api key if no secret provided" do
        config = {
          "client_id": "abc-123",
          "code": "code",
          "redirect_uri": "https://example.com/oauth/callback"
        }

        allow(auth).to receive(:execute).with(
          method: :post,
          path: "#{api_uri}/v3/connect/token",
          query: {},
          payload: {
            client_id: "abc-123",
            code: "code",
            redirect_uri: "https://example.com/oauth/callback",
            client_secret: api_key,
            grant_type: "authorization_code"
          },
          headers: {},
          api_key: api_key,
          timeout: timeout
        )

        auth.exchange_code_for_token(config)
      end
    end

    describe "#refresh_access_token" do
      it "refreshes the access token" do
        config = {
          redirect_uri: "https://example.com/oauth/callback",
          refresh_token: "refresh-12345",
          client_id: "abc-123",
          client_secret: "secret"
        }

        allow(auth).to receive(:execute).with(
          method: :post,
          path: "#{api_uri}/v3/connect/token",
          query: {},
          payload: {
            redirect_uri: "https://example.com/oauth/callback",
            refresh_token: "refresh-12345",
            client_id: "abc-123",
            client_secret: "secret",
            grant_type: "refresh_token"
          },
          headers: {},
          api_key: api_key,
          timeout: timeout
        )

        auth.refresh_access_token(config)
      end

      it "refreshes the access token using the api key if no secret provided" do
        config = {
          redirect_uri: "https://example.com/oauth/callback",
          refresh_token: "refresh-12345",
          client_id: "abc-123"
        }

        allow(auth).to receive(:execute).with(
          method: :post,
          path: "#{api_uri}/v3/connect/token",
          query: {},
          payload: {
            redirect_uri: "https://example.com/oauth/callback",
            refresh_token: "refresh-12345",
            client_id: "abc-123",
            client_secret: api_key,
            grant_type: "refresh_token"
          },
          headers: {},
          api_key: api_key,
          timeout: timeout
        )

        auth.refresh_access_token(config)
      end
    end
  end

  describe "#custom_authentication" do
    it "sends a request with the correct parameters" do
      request = { provider: "google", settings: { foo: "bar" } }

      allow(auth).to receive(:post).with(
        path: "#{api_uri}/v3/connect/custom",
        request_body: request
      )

      auth.custom_authentication(request)
    end
  end

  describe "#revoke_token" do
    it "sends a request with the correct parameters" do
      access_token = "nylas_access_token"
      allow(auth).to receive(:post).with(
        path: "#{api_uri}/v3/connect/revoke",
        query_params: { token: access_token }
      )

      auth.revoke(access_token)
    end
  end

  describe "#detect_provider" do
    it "sends a request with the correct parameters" do
      req = {
        email: "test@gmail.com",
        client_id: "client-123",
        all_provider_types: true
      }
      response = [{
        email_address: "test@gmail.com",
        detected: true,
        provider: "google",
        type: "string"
      }, "mock_request_id"]

      allow(auth).to receive(:post).with(
        path: "#{api_uri}/v3/providers/detect",
        query_params: req
      ).and_return(response)

      expect(auth.detect_provider(req)).to eq(response)
    end
  end
end
