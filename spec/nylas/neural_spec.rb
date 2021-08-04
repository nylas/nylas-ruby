# frozen_string_literal: true

describe Nylas::Neural do
  describe "Clean Conversation" do
    let(:data) do
      [
        {
          account_id: "account123",
          body: "<img src='cid:1781777f666586677621' /> This is the body",
          conversation:
            "<img src='cid:1781777f666586677621' /> This is the conversation",
          date: 1624029503,
          from: [
            {
              email: "swag@nylas.com",
              name: "Nylas Swag"
            }
          ],
          id: "abc123",
          model_version: "0.0.1",
          object: "message",
          provider_name: "gmail",
          subject: "Subject",
          to: [
            {
              email: "me@nylas.com",
              name: "me"
            }
          ]
        }
      ]
    end

    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      clean_conversation = neural.clean_conversation(["abc123"])

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/conversation",
        payload: JSON.dump(
          message_id: ["abc123"]
        )
      )

      expect(clean_conversation.length).to be(1)
      expect(clean_conversation[0].id).to eql("abc123")
      expect(clean_conversation[0].body).to eql("<img src='cid:1781777f666586677621' /> This is the body")
      expect(clean_conversation[0].conversation).to
      eql("<img src='cid:1781777f666586677621' /> This is the conversation")
      expect(clean_conversation[0].model_version).to eql("0.0.1")
    end

    it "Sends the options in the body" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      options = Nylas::NeuralMessageOptions.new(
        ignore_links: false,
        ignore_images: false,
        ignore_tables: false,
        remove_conclusion_phrases: false,
        images_as_markdown: false,
        parse_contact: false
      )
      neural.clean_conversation(["abc123"], options)

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/conversation",
        payload: JSON.dump(
          message_id: ["abc123"],
          ignore_links: false,
          ignore_images: false,
          ignore_tables: false,
          remove_conclusion_phrases: false,
          images_as_markdown: false
        )
      )
    end

    it "Parses the image correctly" do
      api = instance_double(Nylas::API, execute: data)
      files = instance_double(Nylas::Collection, find: Nylas::File.new(id: "file123"))
      allow(api).to receive(:files).and_return(files)
      neural = described_class.new(api: api)
      clean_conversation = neural.clean_conversation(["abc123"])
      clean_conversation[0].extract_images

      expect(files).to have_received(:find).with(
        ["1781777f666586677621"]
      )
    end
  end

  describe "Sentiment Analysis" do
    let(:data) do
      {
        account_id: "abc123",
        processed_length: 17,
        sentiment: "NEUTRAL",
        sentiment_score: 0.20000000298023224,
        text: "This is some text"
      }
    end

    it "Deserializes the message request into Ruby objects" do
      api = instance_double(Nylas::API, execute: [data])
      neural = described_class.new(api: api)
      sentiment = neural.sentiment_analysis_message(["abc123"])

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/sentiment",
        payload: JSON.dump(
          message_id: ["abc123"]
        )
      )

      expect(sentiment.length).to be(1)
      expect(sentiment[0].account_id).to eql("abc123")
      expect(sentiment[0].processed_length).to be(17)
      expect(sentiment[0].sentiment).to eql("NEUTRAL")
      expect(sentiment[0].sentiment_score).to be(0.20000000298023224)
      expect(sentiment[0].text).to eql("This is some text")
    end

    it "Deserializes the text request into Ruby objects" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      sentiment = neural.sentiment_analysis_text("This is some text")

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/sentiment",
        payload: JSON.dump(
          text: "This is some text"
        )
      )

      expect(sentiment.account_id).to eql("abc123")
      expect(sentiment.processed_length).to be(17)
      expect(sentiment.sentiment).to eql("NEUTRAL")
      expect(sentiment.sentiment_score).to be(0.20000000298023224)
      expect(sentiment.text).to eql("This is some text")
    end
  end

  describe "Extract Signature" do
    let(:data) do
      [
        {
          account_id: "account123",
          body:
            "This is the body<div>Nylas Swag</div><div>Software Engineer</div><div>123-456-8901</div>
            <div>swag@nylas.com</div><img src='https://example.com/logo.png'
            alt='https://example.com/link.html'></a>",
          signature:
            "Nylas Swag\n\nSoftware Engineer\n\n123-456-8901\n\nswag@nylas.com",
          contacts: {
            job_titles: ["Software Engineer"],
            links: [
              {
                description: "string",
                url: "https://example.com/link.html"
              }
            ],
            phone_numbers: ["123-456-8901"],
            emails: ["swag@nylas.com"],
            names: [
              {
                first_name: "Nylas",
                last_name: "Swag"
              }
            ]
          },
          date: 1624029503,
          from: [
            {
              email: "swag@nylas.com",
              name: "Nylas Swag"
            }
          ],
          id: "abc123",
          model_version: "0.0.1",
          object: "message",
          provider_name: "gmail",
          subject: "Subject",
          to: [
            {
              email: "me@nylas.com",
              name: "me"
            }
          ]
        }
      ]
    end

    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      signature = neural.extract_signature(["abc123"])

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/signature",
        payload: JSON.dump(
          message_id: ["abc123"]
        )
      )

      expect(signature.length).to be(1)
      expect(signature[0].signature).to
      eql("Nylas Swag\n\nSoftware Engineer\n\n123-456-8901\n\nswag@nylas.com")
      expect(signature[0].model_version).to eql("0.0.1")
      expect(signature[0].contacts.job_titles).to eql(["Software Engineer"])
      expect(signature[0].contacts.phone_numbers).to eql(["123-456-8901"])
      expect(signature[0].contacts.emails).to eql(["swag@nylas.com"])
      expect(signature[0].contacts.links.length).to be(1)
      expect(signature[0].contacts.links[0].description).to eql("string")
      expect(signature[0].contacts.links[0].url).to eql("https://example.com/link.html")
      expect(signature[0].contacts.names.length).to be(1)
      expect(signature[0].contacts.names[0].first_name).to eql("Nylas")
      expect(signature[0].contacts.names[0].last_name).to eql("Swag")
    end

    it "Sends the options in the body" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      options = Nylas::NeuralMessageOptions.new(
        ignore_links: false,
        ignore_images: false,
        ignore_tables: false,
        remove_conclusion_phrases: false,
        images_as_markdown: false,
        parse_contact: false
      )
      neural.extract_signature(["abc123"], options)

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/signature",
        payload: JSON.dump(
          message_id: ["abc123"],
          ignore_links: false,
          ignore_images: false,
          ignore_tables: false,
          remove_conclusion_phrases: false,
          images_as_markdown: false,
          parse_contact: false
        )
      )
    end

    it "Converts signature contact object to a Nylas contact object" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      signature = neural.extract_signature(["abc123"])
      contact = signature[0].contacts.to_contact_object

      expect(contact.given_name).to eql("Nylas")
      expect(contact.surname).to eql("Swag")
      expect(contact.job_title).to eql("Software Engineer")
      expect(contact.emails.length).to be(1)
      expect(contact.emails[0].email).to eql("swag@nylas.com")
      expect(contact.phone_numbers.length).to be(1)
      expect(contact.phone_numbers[0].number).to eql("123-456-8901")
      expect(contact.web_pages.length).to be(1)
      expect(contact.web_pages[0].url).to eql("https://example.com/link.html")
    end
  end

  describe "Categorize" do
    let(:data) do
      {
        account_id: "account123",
        body: "This is a body",
        categorizer: {
          categorized_at: 1624570089,
          category: "feed",
          model_version: "6194f733",
          subcategories: ["ooo"]
        },
        date: 1624029503,
        from: [
          {
            email: "swag@nylas.com",
            name: "Nylas Swag"
          }
        ],
        id: "abc123",
        object: "message",
        provider_name: "gmail",
        subject: "Subject",
        to: [
          {
            email: "me@nylas.com",
            name: "me"
          }
        ]
      }
    end

    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API, execute: [data])
      neural = described_class.new(api: api)
      categorize = neural.categorize(["abc123"])

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/categorize",
        payload: JSON.dump(
          message_id: ["abc123"]
        )
      )

      expect(categorize.length).to be(1)
      expect(categorize[0].categorizer.category).to eql("feed")
      expect(categorize[0].categorizer.categorized_at).to eql(Time.at(1624570089))
      expect(categorize[0].categorizer.model_version).to eql("6194f733")
      expect(categorize[0].categorizer.subcategories.length).to be(1)
      expect(categorize[0].categorizer.subcategories[0]).to eql("ooo")
    end

    it "Re-categorizes the message" do
      api = instance_double(Nylas::API, execute: [data])
      neural = described_class.new(api: api)
      allow(api).to receive(:neural).and_return(neural)
      categorize = neural.categorize(["abc123"])
      new_categorize = categorize[0].recategorize("feed")

      expect(new_categorize.categorizer.category).to eql("feed")
      expect(new_categorize.categorizer.categorized_at).to eql(Time.at(1624570089))
      expect(new_categorize.categorizer.model_version).to eql("6194f733")
      expect(new_categorize.categorizer.subcategories.length).to be(1)
      expect(new_categorize.categorizer.subcategories[0]).to eql("ooo")
    end
  end

  describe "OCR" do
    let(:data) do
      {
        account_id: "account123",
        content_type: "application/pdf",
        filename: "sample.pdf",
        id: "abc123",
        object: "file",
        ocr: ["This is page 1", "This is page 2"],
        processed_pages: 2,
        size: 20
      }
    end

    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API, execute: data)
      neural = described_class.new(api: api)
      ocr = neural.ocr_request("abc123")

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/neural/ocr",
        payload: JSON.dump(
          file_id: "abc123"
        )
      )

      expect(ocr.ocr.length).to be(2)
      expect(ocr.ocr[0]).to eql("This is page 1")
      expect(ocr.ocr[1]).to eql("This is page 2")
      expect(ocr.processed_pages).to be(2)
    end
  end
end
