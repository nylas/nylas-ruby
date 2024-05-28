# frozen_string_literal: true

describe NylasV2::Contacts do
  let(:contacts) { described_class.new(client) }
  let(:response) do
    [{
      birthday: "1960-12-31",
      company_name: "Nylas",
      emails: [{ type: "work", email: "john-work@example.com" }],
      given_name: "John",
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      groups: [{ "id": "starred" }],
      id: "5d3qmne77v32r8l4phyuksl2x",
      im_addresses: [{ type: "other", im_address: "myjabberaddress" }],
      job_title: "Software Engineer",
      manager_name: "Bill",
      middle_name: "Jacob",
      nickname: "JD",
      notes: "Loves ramen",
      object: "contact",
      office_location: "123 Main Street",
      phone_numbers: [{ type: "work", number: "+1-555-555-5555" }],
      physical_addresses: [
        {
          type: "work",
          street_address: "123 Main Street",
          postal_code: 94107,
          state: "CA",
          country: "US",
          city: "San Francisco"
        }
      ],
      picture_url: "https://example.com/picture.jpg",
      suffix: "Jr.",
      surname: "Doe",
      web_pages: [
        { type: "work", url: "http://www.linkedin.com/in/johndoe" }
      ]
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/contacts"
      allow(contacts).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      contacts_response = contacts.list(identifier: identifier, query_params: nil)

      expect(contacts_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/contacts"
      allow(contacts).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      contacts_response = contacts.list(identifier: identifier, query_params: query_params)

      expect(contacts_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      contact_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}"
      allow(contacts).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      contact_response = contacts.find(identifier: identifier, contact_id: contact_id)

      expect(contact_response).to eq(response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      contact_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}"
      allow(contacts).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      contact_response = contacts.find(identifier: identifier, contact_id: contact_id,
                                       query_params: query_params)

      expect(contact_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        given_name: "John",
        surname: "Doe",
        company_name: "Nylas"
      }
      path = "#{api_uri}/v3/grants/#{identifier}/contacts"
      allow(contacts).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      contact_response = contacts.create(identifier: identifier, request_body: request_body)

      expect(contact_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      contact_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        given_name: "John",
        surname: "Doe",
        company_name: "Nylas"
      }
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}"
      allow(contacts).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      contact_response = contacts.update(identifier: identifier, contact_id: contact_id,
                                         request_body: request_body)

      expect(contact_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      contact_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/#{contact_id}"
      allow(contacts).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      contact_response = contacts.destroy(identifier: identifier, contact_id: contact_id)

      expect(contact_response).to eq([true, response[1]])
    end
  end

  describe "#list_groups" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/groups"
      allow(contacts).to receive(:get_list)
        .with(path: path, query_params: nil)

      contacts.list_groups(identifier: identifier, query_params: nil)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/contacts/groups"
      allow(contacts).to receive(:get_list)
        .with(path: path, query_params: query_params)

      contacts.list_groups(identifier: identifier, query_params: query_params)
    end
  end
end
