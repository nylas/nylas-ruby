# frozen_string_literal: true

describe Nylas::Folders do
  let(:folders) { described_class.new(client) }
  let(:response) do
    [{
      id: "SENT",
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      name: "SENT",
      system_folder: true,
      object: "folder",
      unread_count: 0,
      child_count: 0,
      parent_id: "ascsf21412",
      background_color: "#039BE5",
      text_color: "#039BE5",
      total_count: 0
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/folders"
      allow(folders).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      folders_response = folders.list(identifier: identifier)

      expect(folders_response).to eq(list_response)
    end

    it "calls the get method with the correct query parameters including include_hidden_folders" do
      identifier = "abc-123-grant-id"
      query_params = { include_hidden_folders: true }
      path = "#{api_uri}/v3/grants/#{identifier}/folders"
      allow(folders).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      folders_response = folders.list(identifier: identifier, query_params: query_params)

      expect(folders_response).to eq(list_response)
    end
  end

  describe "#find" do
    let(:select_response) do
      [{
        id: "5d3qmne77v32r8l4phyuksl2x",
        grant_id: "abc-123-grant-id"
      }, "mock_request_id"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      folder_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      allow(folders).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      folder_response = folders.find(identifier: identifier, folder_id: folder_id)

      expect(folder_response).to eq(response)
    end

    it "calls the get method with the correct query parameters" do
      identifier = "abc-123-grant-id"
      folder_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { select: "id,grant_id" }
      path = "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      allow(folders).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(select_response)

      folder_response = folders.find(identifier: identifier, folder_id: folder_id, query_params: query_params)

      expect(folder_response).to eq(select_response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        name: "My New Folder",
        parent_id: "parent-folder-id",
        background_color: "#039BE5",
        text_color: "#039BE5"
      }
      path = "#{api_uri}/v3/grants/#{identifier}/folders"
      allow(folders).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      folder_response = folders.create(identifier: identifier, request_body: request_body)

      expect(folder_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      folder_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        name: "My New Folder",
        background_color: "#039BE5",
        text_color: "#039BE5"
      }
      path = "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      allow(folders).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      folder_response = folders.update(identifier: identifier, folder_id: folder_id,
                                       request_body: request_body)

      expect(folder_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      folder_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/folders/#{folder_id}"
      allow(folders).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      folder_response = folders.destroy(identifier: identifier, folder_id: folder_id)

      expect(folder_response).to eq([true, response[1]])
    end
  end
end
