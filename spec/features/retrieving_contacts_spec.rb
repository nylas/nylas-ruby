require 'support/v2_api_helpers'
require 'rspec-given'
describe "Retrieving Contacts via the API" do
  include Nylas::V2::SpecHelpers

  When(:first_contact) { v2_sdk.contacts.first }

  Then { first_contact.is_a? Nylas::V2::Contact }
  Then { first_contact.as_json == fixtures.contacts_page_one.first }
  Then { first_contact.id == fixtures.contacts_page_one.first[:id]  }
end
