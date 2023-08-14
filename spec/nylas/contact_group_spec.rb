# frozen_string_literal: true

describe Nylas::ContactGroup do
  # Restricts the ability to filter a contact group.
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  # Restricts the ability to create a contact group.
  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  # Restricts the ability to update a contact group.
  it "is not updatable" do
    expect(described_class).not_to be_updatable
  end

  # Restricts the ability to destroy a contact group.
  it "is not destroyable" do
    expect(described_class).not_to be_destroyable
  end

  # Allows a contact group to be listed.
  it "is listable" do
    expect(described_class).to be_listable
  end

  # Restricts a contact group from being displayed.
  it "is not showable" do
    expect(described_class).not_to be_showable
  end

  # Sets the resources path for a contact group.
  it "has resources_path" do
    expect(described_class.resources_path).to eq("/contacts/groups")
  end

  # Deserializes a contact group's JSON attributes into Ruby objects.
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
