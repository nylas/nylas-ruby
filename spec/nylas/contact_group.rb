# frozen_string_literal: true

describe Nylas::ContactGroup do
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API)
      data = {
        id: "group-id",
        account_id: "account-id",
        name: "System Group: My Contacts",
        object: "contact_group",
        path: "System Group: My Contacts"
      }

      contact_group = described_class.from_json(JSON.dump(data), api: api)

      expect(contact_group.id).to eq("group-id")
      expect(contact_group.account_id).to eq("account-id")
      expect(contact_group.name).to eq("System Group: My Contacts")
      expect(contact_group.object).to eq("contact_group")
      expect(contact_group.path).to eq("System Group: My Contacts")
    end
  end
end
