require 'spec_helper'

describe Nylas::V1::Contact do
  let(:full_json) do
    '{ "id": "1234", "object": "contact", "account_id": "12345", ' \
      '"name":"given the name", "email": "given-the-name@example.com",' \
      '"phone_numbers": [{ "type": "mobile", "number": "+1234567890" }] ' \
    '}'
  end
  let(:api) { FakeAPI.new }

  describe ".from_json" do
    it "deserializes from JSON" do
      instance = described_class.from_json(full_json, api: api)
      expect(instance.id).to eql "1234"
      expect(instance.object).to eql "contact"
      expect(instance.account_id).to eql "12345"
      expect(instance.name).to eql "given the name"
      expect(instance.email).to eql "given-the-name@example.com"
      expect(instance.phone_numbers.size).to eql 1
      expect(instance.phone_numbers.first.type).to eql "mobile"
      expect(instance.phone_numbers.first.number).to eql "+1234567890"
    end

  end
  describe "#to_json" do
    it "can be serialized back into JSON without loss" do
      instance = described_class.from_json(full_json, api: api)
      expect(JSON.parse(instance.to_json)).to eql(JSON.parse(full_json))
    end
  end

  describe "#save" do
    it "raises ane xception since V1 of the contacts API is read only" do
      instance = described_class.from_json(full_json, api: api)
      expect { instance.save }.to raise_error(NotImplementedError, "#{described_class} is read only")
    end
  end

  describe "#update" do
    it "raises ane xception since V1 of the contacts API is read only" do
      instance = described_class.from_json(full_json, api: api)
      expect { instance.update(name: "other") }.to raise_error(NotImplementedError,
                                                               "#{described_class} is read only")
    end
  end

  describe "A collection of contacts" do
    subject(:contacts) { Nylas::Collection.new(model: described_class, api: api) }
    describe "#find" do
      it "Retrieves the expected contact from the expected endpoint" do
        contact_hash = JSON.parse(full_json, symbolize_names: true)
        allow(api).to receive(:execute).with(method: :get, path: '/contacts/1234').and_return(contact_hash)

        contact = contacts.find(1234)

        expect(contact.id).to eql "1234"
      end
    end

    describe "#each" do
      it "retrieves a page of 100 contacts from the expected endpoint" do
        contact_hash = JSON.parse(full_json, symbolize_names: true)

        allow(api).to receive(:execute).with(method: :get, path: '/contacts', query: { limit: 100, offset: 0 }).and_return([contact_hash])

        expect(contacts.each.to_a.count).to eql 1
      end
    end

    describe "#find_each" do
      it "retrieves every page of 100 contacts from the expected endpoint" do

        contact_hash = JSON.parse(full_json, symbolize_names: true)

        allow(api).to receive(:execute).with(method: :get, path: '/contacts', query: { limit: 100, offset: 0 }).and_return(100.times.map { contact_hash })
        allow(api).to receive(:execute).with(method: :get, path: '/contacts', query: { limit: 100, offset: 100 }).and_return(50.times.map { contact_hash })

        expect(contacts.find_each.to_a.count).to eql 150
      end
    end

    describe "#where" do
      it "raises a NotImplementedError stating that the v1 of the contacts API does not support search" do
        expect { contacts.where(id: '1234') }.to raise_error(NotImplementedError, "#{described_class} does not support search")
      end
    end

    describe "#create" do
      it "raises a NotImplementedError stating that the v1 of the contacts API is read only" do
        expect { contacts.create(id: '1234') }.to raise_error(NotImplementedError, "#{described_class} is read only")
      end
    end
  end
end
