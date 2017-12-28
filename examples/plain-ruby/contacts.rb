require_relative '../helpers'
# An executable specification that demonstrates how to use the Nylas Ruby SDK to interact with the API. It
# follows the rough structure of the [Nylas API Reference](https://docs.nylas.com/reference).
api = Nylas::API.new(app_id: ENV['NYLAS_APP_ID'], app_secret: ENV['NYLAS_APP_SECRET'],
                     access_token: ENV['NYLAS_ACCESS_TOKEN'])
# Retrieving a count of contacts
demonstrate { api.contacts.count }

# Retrieving a subset of contacts using limit
demonstrate { api.contacts.limit(5).map(&:to_h) }

data = {
  given_name: Faker::Name.first_name,
  surname: Faker::Name.last_name,
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
}
contact = api.contacts.create(data)


# Searching contacts!
demonstrate do
  #api.contacts.where(email: contact.email_addresses.first.email,
  #                   country: contact.physical_addresses.first.country,
  #                   phone_number: contact.phone_numbers.first.number,
  #                   street_address: contact.physical_addresses.first.street_address).map(&:to_h)

end

# Retrieve all pages of contacts
demonstrate { api.contacts.find_each.map(&:to_h) }

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

# Destroying a contact
demonstrate { contact.destroy }
