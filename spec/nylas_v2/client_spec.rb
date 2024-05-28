# frozen_string_literal: true

describe NylasV2::Client do
  describe "#initialize" do
    context "when only provided an API key" do
      it "constructs with the correct default values" do
        nylas = described_class.new(api_key: "fake-key")

        expect(nylas.api_key).to eq("fake-key")
        expect(nylas.api_uri).to eq("https://api.us.nylas.com")
        expect(nylas.timeout).to eq(90)
      end
    end

    context "when provided an API key and custom API URI" do
      it "constructs with the correct values" do
        nylas = described_class.new(api_key: "fake-key", api_uri: "https://custom.nylas.com")

        expect(nylas.api_key).to eq("fake-key")
        expect(nylas.api_uri).to eq("https://custom.nylas.com")
        expect(nylas.timeout).to eq(90)
      end
    end

    context "when provided an API key and timeout" do
      it "constructs with the correct values" do
        nylas = described_class.new(api_key: "fake-key", timeout: 60)

        expect(nylas.api_key).to eq("fake-key")
        expect(nylas.api_uri).to eq("https://api.us.nylas.com")
        expect(nylas.timeout).to eq(60)
      end
    end
  end

  describe "methods" do
    context "with a configured Client instance" do
      it "returns the correct resources" do
        nylas = described_class.new(api_key: "fake-key")

        expect(nylas.applications).to be_a(NylasV2::Applications)
        expect(nylas.attachments).to be_a(NylasV2::Attachments)
        expect(nylas.auth).to be_a(NylasV2::Auth)
        expect(nylas.calendars).to be_a(NylasV2::Calendars)
        expect(nylas.connectors).to be_a(NylasV2::Connectors)
        expect(nylas.contacts).to be_a(NylasV2::Contacts)
        expect(nylas.drafts).to be_a(NylasV2::Drafts)
        expect(nylas.events).to be_a(NylasV2::Events)
        expect(nylas.grants).to be_a(NylasV2::Grants)
        expect(nylas.folders).to be_a(NylasV2::Folders)
        expect(nylas.messages).to be_a(NylasV2::Messages)
        expect(nylas.threads).to be_a(NylasV2::Threads)
        expect(nylas.webhooks).to be_a(NylasV2::Webhooks)
      end
    end
  end
end
