require "spec_helper"

describe Nylas::Model do
  def example_instance_json
    "{ }"
  end

  def example_instance_hash
    JSON.parse(example_instance_json, symbolize_names: true)
  end

  let(:api) { FakeAPI.new }

  describe "#to_json" do
    it "dumps all the defined attributes to JSON"
  end

  describe "#save" do
    it "raises a NotImplementedError exception if the model is flagged as not updatable" do
      instance = NotUpdatableModel.from_hash({ id: "model-1234" }, api: api)
      expect { instance.save }.to raise_error(Nylas::ModelNotUpdatableError)
    end

    it "raises a ModelNotCreatable exception if the model is new and is flagged as not creatable" do
      instance = NotCreatableModel.from_hash({}, api: api)
      expect { instance.save }.to raise_error(Nylas::ModelNotCreatableError)
    end
  end

  describe "#update" do
    it "raises a NotImplementedError exception if the model is flagged as read only" do
      instance = NotUpdatableModel.from_json(example_instance_json, api: api)
      expect { instance.update(name: "other") }.to raise_error(Nylas::ModelNotUpdatableError)
    end

    it "raises a MissingFieldError if attempting to set a field that does not exist" do
      expected_message = "fake_attribute is not a valid attribute for FullModel"
      instance = FullModel.new
      expect do
        instance.update(fake_attribute: "not real")
      end.to raise_error(Nylas::ModelMissingFieldError, expected_message)
    end
  end

  describe ".from_json(json, api:)" do
    it "instantiates a ruby version of the Model with pas the data" do
      instance = FullModel.from_json("{}", api: api)
      expect(instance.api).to eql(api)
    end

    it "instantiates gracefully even if the api responds with additional fields" do
      expect { FullModel.from_json('{ "missing-attribute": 1234 }', api: api) }.not_to raise_error
    end

    it "supports date attributes" do
      instance = FullModel.from_json('{ "date": "2017-01-01" }', api: api)
      expect(instance.date).to eql(Date.parse("2017-01-01"))
    end
    it "supports email address attributes" do
      instance = FullModel.from_json('{ "email_address": { "type": "home", "email": "test@example.com" } }',
                                     api: api)
      expect(instance.email_address.type).to eql "home"
      expect(instance.email_address.email).to eql "test@example.com"
    end

    it "supports im address attributes" do
      im_json = '{ "im_address": { "type": "gmail", "im_address": "test@example.com" } }'
      instance = FullModel.from_json(im_json, api: api)
      expect(instance.im_address.type).to eql "gmail"
      expect(instance.im_address.im_address).to eql "test@example.com"
    end

    it "supports nylas date attributes" do
      instance = FullModel.from_json('{ "nylas_date": { "object": "date", "date": "2017-01-01" } }',
                                     api: api)
      expect(instance.nylas_date.object).to eql "date"
      expect(instance.nylas_date.date).to eql Date.parse("2017-01-01")
      expect(instance.nylas_date).to eql Date.parse("2017-01-01")
    end

    it "supports physical address attributes" do
      address_json = JSON.dump(format: "structured", type: "work", street_address: "123 N West St",
                               postal_code: "12345+0987", state: "CA", country: "USA")
      instance = FullModel.from_json('{ "physical_address": ' + address_json + " } ", api: api)
      expect(instance.physical_address.format).to eql "structured"
      expect(instance.physical_address.type).to eql "work"
      expect(instance.physical_address.street_address).to eql("123 N West St")
      expect(instance.physical_address.postal_code).to eql("12345+0987")
      expect(instance.physical_address.state).to eql("CA")
      expect(instance.physical_address.country).to eql("USA")
    end

    it "supports phone number attributes" do
      instance = FullModel.from_json('{ "phone_number": { "type": "mobile", "number": "+1234567890" } }',
                                     api: api)
      expect(instance.phone_number.type).to eql "mobile"
      expect(instance.phone_number.number).to eql "+1234567890"
    end

    it "supports string attributes" do
      instance = FullModel.from_json('{ "string": "value" }', api: api)
      expect(instance.string).to eql "value"
    end

    it "supports web page attributes" do
      instance = FullModel.from_json('{ "web_page": { "type": "profile", "url": "http://example.com"} }',
                                     api: api)
      expect(instance.web_page.type).to eql "profile"
      expect(instance.web_page.url).to eql "http://example.com"
    end

    it "supports when there are many of a type in an attribute" do
      instance = FullModel.from_json('{ "web_pages": [{ "type": "profile", "url": "http://example.com"}] }',
                                     api: api)
      expect(instance.web_pages.first.type).to eql "profile"
      expect(instance.web_pages.first.url).to eql "http://example.com"
    end
  end
end
