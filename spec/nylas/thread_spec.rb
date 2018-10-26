require "spec_helper"

describe Nylas::Thread do
  it "is filterable" do
    expect(described_class).to be_filterable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  it "is updatable" do
    expect(described_class).to be_updatable
  end

  it "can be deserialized from JSON" do
    api = instance_double(Nylas::API)
    json = JSON.dump(id: "thread-2345", account_id: "acc-1234", draft_ids: ["dra-987"],
                     first_message_timestamp: 1_510_080_143, has_attachments: false,
                     labels: [{ display_name: "All Mail", id: "label-all-mail", name: "all" },
                              { display_name: "Inbox", id: "label-inbox", name: "inbox" }],
                     folders: [{ display_name: "All Mail", id: "folder-all-mail", name: "all" },
                               { display_name: "Inbox", id: "folder-inbox", name: "inbox" }],
                     last_message_received_timestamp: 1_510_080_143, last_message_sent_timestamp: nil,
                     last_message_timestamp: 1_510_080_143, message_ids: ["mess-0987"],
                     object: "thread", participants: [{ email: "hellocohere@gmail.com", name: "" },
                                                      { email: "andy-noreply@google.com",
                                                        name: "Andy from Google" }],
                     snippet: "Hi there!", starred: false, subject: "Hello!", "unread": false, "version": 2)

    thread = described_class.from_json(json, api: api)
    expect(thread.id).to eql "thread-2345"
    expect(thread.account_id).to eql "acc-1234"
    expect(thread.draft_ids).to eql ["dra-987"]
    expect(thread.first_message_timestamp).to eql Time.at(1_510_080_143)
    expect(thread.has_attachments).to be false

    expect(thread.labels[0].id).to eql "label-all-mail"
    expect(thread.labels[0].name).to eql "all"
    expect(thread.labels[0].display_name).to eql "All Mail"
    expect(thread.labels[0].api).to be api

    expect(thread.labels[1].id).to eql "label-inbox"
    expect(thread.labels[1].name).to eql "inbox"
    expect(thread.labels[1].display_name).to eql "Inbox"
    expect(thread.labels[1].api).to be api

    expect(thread.last_message_received_timestamp).to eql Time.at(1_510_080_143)
    expect(thread.last_message_timestamp).to eql Time.at(1_510_080_143)

    expect(thread.message_ids).to eql(["mess-0987"])
    expect(thread.object).to eql "thread"
    expect(thread.participants[0].email).to eql "hellocohere@gmail.com"
    expect(thread.participants[0].name).to eql ""
    expect(thread.participants[1].email).to eql "andy-noreply@google.com"
    expect(thread.participants[1].name).to eql "Andy from Google"
    expect(thread.snippet).to eql "Hi there!"
    expect(thread).not_to be_starred
    expect(thread.subject).to eql "Hello!"
    expect(thread).not_to be_unread
    expect(thread.version).to be 2
  end

  describe "#update" do
    it "let's you set the starred, unread, folder, and label ids" do
      api =  instance_double(Nylas::API, execute: "{}")
      thread = described_class.from_json('{ "id": "thread-1234" }', api: api)
      thread.update(starred: true, unread: false, folder_id: "folder-1234",
                    label_ids: ["label-1234", "label-4567"])

      expect(api).to have_received(:execute).with(method: :put, path: "/threads/thread-1234",
                                                  payload: JSON.dump(starred: true, unread: false,
                                                                     folder_id: "folder-1234",
                                                                     label_ids: ["label-1234",
                                                                                 "label-4567"]))
    end

    it "raises an argument error if the data has any keys that aren't allowed to be updated" do
      api =  instance_double(Nylas::API, execute: "{}")
      thread = described_class.from_json('{ "id": "thread-1234" }', api: api)
      expect do
        thread.update(subject: "A new subject!")
      end.to raise_error ArgumentError, "Cannot update [:subject] only " \
                                        "#{described_class::UPDATABLE_ATTRIBUTES} are updatable"
    end
  end
end
