require 'spec_helper'

class FakeAPI
end
describe Nylas::V2::Contact do
  describe ".from_json" do
    it "deserializes into a fully inflated Contact object" do
      api = FakeAPI.new
      c = described_class.from_json('{ "id": "1234", "object": "contact", "account_id": "12345", ' \
                                    '"given_name":"given", "middle_name": "middle", "surname": "surname", ' \
                                    '"birthday": "1984-01-01", "suffix": "Jr.", "nickname": "nick", ' \
                                    '"company_name": "company", "job_title": "title", ' \
                                    '"manager_name": "manager", "office_location": "the office", ' \
                                    '"notes": "some notes", "email_addresses": [' \
                                      '{ "type": "work", "email": "given@work.example.com" }, ' \
                                      '{ "type": "home", "email": "given@home.example.com" }], ' \
                                    '"im_addresses": [{ "type": "gtalk", ' \
                                                       '"im_address": "given@gtalk.example.com" }],' \
                                    '"physical_addresses": [{ "format": "structured", "type": "work",' \
                                                             '"street_address": "123 N West St",' \
                                                             '"postal_code": "12345+0987", "state": "CA",' \
                                                             '"country": "USA" }],' \
                                    '"phone_numbers": [{ "type": "mobile", "number": "+1234567890" }], ' \
                                    '"web_pages": [{ "type": "profile", "url": "http://given.example.com" }] ' \
                                    '}', api: api)

      expect(c.id).to eql("1234")
      expect(c.object).to eql("contact")
      expect(c.account_id).to eql("12345")
      expect(c.given_name).to eql("given")
      expect(c.middle_name).to eql("middle")
      expect(c.surname).to eql("surname")
      expect(c.birthday).to eql(Date.parse("1984-01-01"))
      expect(c.suffix).to eql("Jr.")
      expect(c.nickname).to eql("nick")
      expect(c.company_name).to eql("company")
      expect(c.job_title).to eql("title")
      expect(c.manager_name).to eql("manager")
      expect(c.office_location).to eql("the office")
      expect(c.notes).to eql("some notes")
      expect(c.email_addresses[0].type).to eql("work")
      expect(c.email_addresses[0].email).to eql("given@work.example.com")
      expect(c.email_addresses[1].type).to eql("home")
      expect(c.email_addresses[1].email).to eql("given@home.example.com")
      expect(c.im_addresses[0].type).to eql("gtalk")
      expect(c.im_addresses[0].im_address).to eql("given@gtalk.example.com")
      expect(c.physical_addresses[0].type).to eql("work")
      expect(c.physical_addresses[0].format).to eql("structured")
      expect(c.physical_addresses[0].street_address).to eql("123 N West St")
      expect(c.physical_addresses[0].postal_code).to eql("12345+0987")
      expect(c.physical_addresses[0].state).to eql("CA")
      expect(c.physical_addresses[0].country).to eql("USA")
      expect(c.phone_numbers[0].type).to eql("mobile")
      expect(c.phone_numbers[0].number).to eql("+1234567890")
      expect(c.web_pages[0].type).to eql("profile")
      expect(c.web_pages[0].url).to eql("http://given.example.com")
    end

    describe "#to_h" do
      it "serializes the attributes into a hash of primitives"
    end

    describe "#to_json" do
    end
  end
end
