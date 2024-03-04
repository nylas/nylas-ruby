# frozen_string_literal: true

describe Nylas::Client do
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

        expect(nylas.applications).to be_a(Nylas::Applications)
        expect(nylas.attachments).to be_a(Nylas::Attachments)
        expect(nylas.auth).to be_a(Nylas::Auth)
        expect(nylas.calendars).to be_a(Nylas::Calendars)
        expect(nylas.connectors).to be_a(Nylas::Connectors)
        expect(nylas.contacts).to be_a(Nylas::Contacts)
        expect(nylas.drafts).to be_a(Nylas::Drafts)
        expect(nylas.events).to be_a(Nylas::Events)
        expect(nylas.grants).to be_a(Nylas::Grants)
        expect(nylas.folders).to be_a(Nylas::Folders)
        expect(nylas.messages).to be_a(Nylas::Messages)
        expect(nylas.threads).to be_a(Nylas::Threads)
        expect(nylas.webhooks).to be_a(Nylas::Webhooks)
      end
    end
  end
end
