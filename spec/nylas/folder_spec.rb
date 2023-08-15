# frozen_string_literal: true

describe Nylas::Folder do
  # Restrict the ability to filter on a folder.
  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  # Allow a folder to be listed.
  it "is listable" do
    expect(described_class).to be_listable
  end

  # Allow a folder to be created.
  it "is creatable" do
    expect(described_class).to be_creatable
  end

  # Allow a folder to be updated.
  it "is updatable" do
    expect(described_class).to be_updatable
  end

  # Allow a folder to be destroyed.
  it "is destroyable" do
    expect(described_class).to be_destroyable
  end

  # API operations for creating, updating, and deleting folders.
  describe "API operations" do
    # Send a POST call when a new folder is saved.
    it "sends a POST when saving a new folder" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      json = JSON.dump(display_name: "All Mail", name: "all")
      folder = described_class.from_json(json, api: api)
      allow(api).to receive(:execute).and_return({})

      folder.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :post,
        path: "/folders",
        payload: {
          name: "all",
          display_name: "All Mail"
        }.to_json,
        query: {}
      )
    end

    # Send a PUT call when a folder is updated.
    it "sends a PUT when updating an existing folder" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      json = JSON.dump(id: "folder_id", display_name: "All Mail", name: "all", account_id: "acc-234",
                       object: "folder")
      folder = described_class.from_json(json, api: api)
      allow(api).to receive(:execute).and_return({})

      folder.update(
        display_name: "New Display Name"
      )

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/folders/folder_id",
        payload: {
          display_name: "New Display Name"
        }.to_json,
        query: {}
      )
    end

    # Send a PUT call when an existing folder is saved.
    it "sends a PUT when saving an existing folder" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      json = JSON.dump(id: "folder_id", display_name: "All Mail", name: "all", account_id: "acc-234",
                       object: "folder")
      folder = described_class.from_json(json, api: api)
      allow(api).to receive(:execute).and_return({})

      folder.save

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :put,
        path: "/folders/folder_id",
        payload: {
          name: "all",
          display_name: "All Mail"
        }.to_json,
        query: {}
      )
    end

    # Send a DELETE call when a folder is deleted.
    it "sends a DELETE when deleting an existing folder" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      json = JSON.dump(id: "folder_id", display_name: "All Mail", name: "all", account_id: "acc-234",
                       object: "folder")
      folder = described_class.from_json(json, api: api)
      allow(api).to receive(:execute).and_return({})

      folder.destroy

      expect(api).to have_received(:execute).with(
        auth_method: Nylas::HttpClient::AuthMethod::BEARER,
        method: :delete,
        path: "/folders/folder_id",
        payload: nil,
        query: {}
      )
    end
  end

  # Deserialize a folder's JSON attributes into Ruby objects.
  describe "#from_json" do
    it "deserializes all the attributes successfully" do
      json = JSON.dump(display_name: "All Mail", id: "folder-all-mail", name: "all", account_id: "acc-234")
      folder = described_class.from_json(json, api: nil)
      expect(folder.display_name).to eql "All Mail"
      expect(folder.id).to eql "folder-all-mail"
      expect(folder.name).to eql "all"
      expect(folder.account_id).to eql "acc-234"
    end
  end
end
