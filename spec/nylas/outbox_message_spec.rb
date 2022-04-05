# frozen_string_literal: true

require "spec_helper"

describe Nylas::OutboxMessage do
  it "Deserializes all the attributes into Ruby objects" do
    api = instance_double(Nylas::API)
    data = { send_at: 1649179701, retry_limit_datetime: 1649266101, original_send_at: 1649179701,
             account_id: "acc-9987", thread_id: "thread-1234", reply_to_message_id: "mess-1234",
             date: 1_513_276_982, to: [{ email: "to@example.com", name: "To Example" }],
             from: [{ email: "from@example.com", name: "From Example" }],
             cc: [{ email: "cc@example.com", name: "CC Example" }],
             bcc: [{ email: "bcc@example.com", name: "BCC Example" }],
             reply_to: [{ email: "reply-to@example.com", name: "Reply To Example" }],
             subject: "A outbox_message emails subject", snippet: "A outbox_message Email",
             body: "<h1>A outbox_message Email</h1>", starred: false, unread: false, events: [],
             files: [{ content_type: "text/calendar", filename: nil, id: "file-abc35", size: 1264 },
                     { content_type: "application/ics", filename: "invite.ics", id: "file-xyz-9234",
                       size: 1264 }],
             folder: { display_name: "Inbox", id: "folder-inbox", name: "inbox" },
             labels: [{ display_name: "Inbox", id: "label-inbox", name: "inbox" },
                      { display_name: "All Mail", id: "label-all", name: "all" }],
             metadata: { test: "yes" },
             tracking: { opens: true, links: true, thread_replies: true, payload: "this is a payload" } }

    outbox_message = described_class.from_json(JSON.dump(data), api: api)
    expect(outbox_message.send_at).to eql Time.at(1649179701)
    expect(outbox_message.retry_limit_datetime).to eql Time.at(1649266101)
    expect(outbox_message.original_send_at).to eql Time.at(1649179701)

    expect(outbox_message.account_id).to eql "acc-9987"
    expect(outbox_message.thread_id).to eql "thread-1234"
    expect(outbox_message.reply_to_message_id).to eql "mess-1234"
    expect(outbox_message.date).to eql Time.at(1_513_276_982)

    expect(outbox_message.to[0].email).to eql "to@example.com"
    expect(outbox_message.to[0].name).to eql "To Example"

    expect(outbox_message.from[0].email).to eql "from@example.com"
    expect(outbox_message.from[0].name).to eql "From Example"

    expect(outbox_message.cc[0].email).to eql "cc@example.com"
    expect(outbox_message.cc[0].name).to eql "CC Example"

    expect(outbox_message.bcc[0].email).to eql "bcc@example.com"
    expect(outbox_message.bcc[0].name).to eql "BCC Example"

    expect(outbox_message.reply_to[0].email).to eql "reply-to@example.com"
    expect(outbox_message.reply_to[0].name).to eql "Reply To Example"

    expect(outbox_message.subject).to eql "A outbox_message emails subject"
    expect(outbox_message.snippet).to eql "A outbox_message Email"
    expect(outbox_message.body).to eql "<h1>A outbox_message Email</h1>"

    expect(outbox_message).not_to be_starred
    expect(outbox_message).not_to be_unread

    expect(outbox_message.files[0].content_type).to eql "text/calendar"
    expect(outbox_message.files[0].filename).to be_nil
    expect(outbox_message.files[0].id).to eql "file-abc35"
    expect(outbox_message.files[0].size).to be 1264
    expect(outbox_message.files[0].api).to be api

    expect(outbox_message.files[1].content_type).to eql "application/ics"
    expect(outbox_message.files[1].filename).to eql "invite.ics"
    expect(outbox_message.files[1].id).to eql "file-xyz-9234"
    expect(outbox_message.files[1].size).to be 1264
    expect(outbox_message.files[1].api).to be api

    # Note, outbox_messages will either be in a folder *or* labeled, not both.
    expect(outbox_message.folder.display_name).to eql "Inbox"
    expect(outbox_message.folder.name).to eql "inbox"
    expect(outbox_message.folder.id).to eql "folder-inbox"
    expect(outbox_message.folder.api).to be api

    expect(outbox_message.labels[0].display_name).to eql "Inbox"
    expect(outbox_message.labels[0].id).to eql "label-inbox"
    expect(outbox_message.labels[0].name).to eql "inbox"
    expect(outbox_message.labels[0].api).to be api

    expect(outbox_message.labels[1].display_name).to eql "All Mail"
    expect(outbox_message.labels[1].id).to eql "label-all"
    expect(outbox_message.labels[1].name).to eql "all"
    expect(outbox_message.labels[1].api).to be api

    expect(outbox_message.metadata).to eq(test: "yes")

    expect(outbox_message.tracking.opens).to be true
    expect(outbox_message.tracking.links).to be true
    expect(outbox_message.tracking.thread_replies).to be true
    expect(outbox_message.tracking.payload).to eql "this is a payload"
  end
end
