require_relative 'helpers'

# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API
# It follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).

# ### V2
# To create a connection to the Nylas SDK using V2 of the API:
api = Nylas::API.new(api_version: "2", app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])

# Retrieving a count of contacts
demonstrate { api.contacts.count }

# Retrieving a subset of contacts using limit
demonstrate { api.contacts.limit(5).map(&:to_h) }

new_contacts = 20.times.map do
  data = {
    physical_addresses: [{ format: "structured",
                             type: ['home', 'work', nil].sample,
                             street_address: Faker::Address.street_address,
                             postal_code: Faker::Address.postcode,
                             city: Faker::Address.city,
                             state: Faker::Address.state,
                             country: ["USA", "America", "Canada"].sample }],
    phone_numbers: [{ type: ['business', 'home', 'mobile', 'pager', 'business_fax', 'home_fax',
                             'organization_main', 'assistant', 'radio'].sample,
                      number: Faker::PhoneNumber.cell_phone }],
    email_addresses: [{ type: ['personal', 'work', nil].sample, email: Faker::Internet.safe_email }],
    web_pages: [{ type: ['profile', 'blog', 'homepage', 'work'].sample, url: Faker::Internet.url('example.com') }],
    web_page: { type: ['profile', 'blog', 'homepage', 'work'].sample, url: Faker::Internet.url('example.com') },
    given_name: Faker::Name.first_name,
    surname: Faker::Name.last_name
  }
  begin
    contact = api.contacts.create(data)
  rescue Nylas::InternalError => e
    Nylas::Logging.logger.error(data)
    Nylas::Logging.logger.error(e.message)
  end
  contact
end.compact


# Searching!
# demonstrate { api.contacts.where(email: new_contacts[8].email_addresses.first.email).limit(3).map(&:to_h) }
demonstrate { api.contacts.where(state: new_contacts[3].physical_addresses.first.state).limit(3).map(&:to_h) }
demonstrate { api.contacts.where(country: new_contacts[5].physical_addresses.first.country).limit(3).map(&:to_h) }
demonstrate { api.contacts.where(phone_number: new_contacts[12].phone_numbers.first.number).limit(3).map(&:to_h) }
demonstrate { api.contacts.where(street_address: new_contacts[13].physical_addresses.first.street_address).limit(3).map(&:to_h) }

# Retrieving the first page of contacts
demonstrate { api.contacts.map(&:to_h) }

# Retrieve all pages of contacts
# demonstrate { api.contacts.find_each.map(&:to_h) }

contact = api.contacts.first
# Updating a contact
demonstrate { contact.update(surname: Faker::Name.last_name) }

# Retrieving a contact by ID
same_contact_different_instance = demonstrate { api.contacts.find(contact.id) }

# Updating a found contact
demonstrate do
  same_contact_different_instance.update(surname: Faker::Name.last_name)
  same_contact_different_instance.surname
end

# Reloading a contact
demonstrate { contact.reload }
demonstrate { contact.surname }

