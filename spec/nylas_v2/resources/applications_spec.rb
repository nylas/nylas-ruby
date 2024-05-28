# frozen_string_literal: true

describe NylasV2::Applications do
  let(:application) { described_class.new(client) }
  let(:response) do
    [{
      "application_id": "ad410018-d306-43f9-8361-fa5d7b2172e0",
      "organization_id": "f5db4482-dbbe-4b32-b347-61c260d803ce",
      "region": "us",
      "environment": "production",
      "branding": {
        "name": "My application",
        "icon_url": "https://my-app.com/my-icon.png",
        "website_url": "https://my-app.com",
        "description": "Online banking application."
      },
      "hosted_authentication": {
        "background_image_url": "https://my-app.com/bg.jpg",
        "alignment": "left",
        "color_primary": "#dc0000",
        "color_secondary": "#000056",
        "title": "string",
        "subtitle": "string",
        "background_color": "#003400",
        "spacing": 5
      },
      "callback_uris": [
        {
          "id": "0556d035-6cb6-4262-a035-6b77e11cf8fc",
          "url": "string",
          "platform": "web",
          "settings": {
            "origin": "string",
            "bundle_id": "string",
            "package_name": "string",
            "sha1_certificate_fingerprint": "string"
          }
        }
      ]
    }, "mock_request_id"]
  end

  describe "#initialize" do
    it "initializes the RedirectURIs object" do
      expect(application.redirect_uris).to be_a(NylasV2::RedirectUris)
    end
  end

  describe "#get_details" do
    it "calls the get method with the correct parameters" do
      path = "#{api_uri}/v3/applications"
      allow(application).to receive(:get)
        .with(path: path)
        .and_return(response)

      response = application.get_details

      expect(response).to eq(response)
    end
  end
end
