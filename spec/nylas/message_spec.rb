# frozen_string_literal: true

describe Nylas::Message do
  describe ".from_json" do
    it "Deserializes all the attributes into Ruby objects" do
      api = instance_double(Nylas::API)
      data = { id: "mess-8766", object: "message", account_id: "acc-1234", thread_id: "thread-1234",
               date: 1_511_302_748,
               to: [{ email: "to@example.com", name: "To Example" }],
               from: [{ email: "from@example.com", name: "From Example" }],
               cc: [{ email: "cc@example.com", name: "CC Example" }],
               bcc: [{ email: "bcc@example.com", name: "BCC Example" }],
               reply_to: [{ email: "reply-to@example.com", name: "Reply To Example" }],
               subject: "Security alert",
               snippet: "a string of the body that has no html in it",
               body: "<html lang='en'><p>A string that probably has HTML in it</p></html>",
               starred: true, unread: true,
               events: [{ account_id: "acc-1234", busy: true, calendar_id: "cal-0987",
                          description: "an event", id: "evnt-2345", location: "", message_id: "mess-8766",
                          object: "event", owner: '"owner" <owner@example.com>',
                          participants: [{ comment: "Let me think on it", email: "participant@example.com",
                                           name: "Participant", status: "noreply" },
                                         { comment: nil, email: "owner@example.com", name: "Owner",
                                           status: "yes" }],
                          read_only: true, status: "confirmed", title: "An Event",
                          when: { end_time: 1_511_306_400, object: "timespan",
                                  start_time: 1_511_303_400 } }],
               files: [{ content_type: "text/calendar", filename: nil, id: "file-abc35", size: 1264 },
                       { content_type: "application/ics", filename: "invite.ics", id: "file-xyz-9234",
                         size: 1264 }],
               folder: { display_name: "Inbox", id: "folder-inbox", name: "inbox" },
               labels: [{ display_name: "Inbox", id: "label-inbox", name: "inbox" },
                        { display_name: "All Mail", id: "label-all", name: "all" }] }

      message = described_class.from_json(JSON.dump(data), api: api)
      expect(message.id).to eql "mess-8766"
      expect(message.account_id).to eql "acc-1234"
      expect(message.thread_id).to eql "thread-1234"
      expect(message.date).to eql Time.at(1_511_302_748)

      expect(message.to[0].email).to eql "to@example.com"
      expect(message.to[0].name).to eql "To Example"

      expect(message.from[0].email).to eql "from@example.com"
      expect(message.from[0].name).to eql "From Example"

      expect(message.cc[0].email).to eql "cc@example.com"
      expect(message.cc[0].name).to eql "CC Example"

      expect(message.bcc[0].email).to eql "bcc@example.com"
      expect(message.bcc[0].name).to eql "BCC Example"

      expect(message.reply_to[0].email).to eql "reply-to@example.com"
      expect(message.reply_to[0].name).to eql "Reply To Example"

      expect(message.subject).to eql "Security alert"
      expect(message.snippet).to eql "a string of the body that has no html in it"
      expect(message.body).to eql "<html lang='en'><p>A string that probably has HTML in it</p></html>"

      expect(message).to be_starred
      expect(message).to be_unread

      event = message.events[0]

      expect(event.id).to eql "evnt-2345"
      expect(event.object).to eql "event"
      expect(event.account_id).to eql "acc-1234"
      expect(event.message_id).to eql "mess-8766"
      expect(event.api).to be api

      expect(event).to be_busy
      expect(event.calendar_id).to eql "cal-0987"
      expect(event.description).to eql "an event"
      expect(event.owner).to eql '"owner" <owner@example.com>'
      expect(event.participants[0].comment).to eql "Let me think on it"
      expect(event.participants[0].email).to eql "participant@example.com"
      expect(event.participants[0].name).to eql "Participant"
      expect(event.participants[0].status).to eql "noreply"

      expect(event.participants[1].comment).to be_nil
      expect(event.participants[1].email).to eql "owner@example.com"
      expect(event.participants[1].name).to eql "Owner"
      expect(event.participants[1].status).to eql "yes"

      expect(event).to be_read_only
      expect(event.status).to eql "confirmed"
      expect(event.title).to eql "An Event"
      expect(event.when.start_time).to eql Time.at(1_511_303_400)
      expect(event.when).to cover(Time.at(1_511_303_400))
      expect(event.when).not_to cover(Time.at(1_511_303_399))
      expect(event.when.end_time).to eql Time.at(1_511_306_400)
      expect(event.when).to cover(Time.at(1_511_306_400))
      expect(event.when).not_to cover(Time.at(1_511_306_401))

      expect(message.files[0].content_type).to eql "text/calendar"
      expect(message.files[0].filename).to be_nil
      expect(message.files[0].id).to eql "file-abc35"
      expect(message.files[0].size).to be 1264
      expect(message.files[0].api).to be api

      expect(message.files[1].content_type).to eql "application/ics"
      expect(message.files[1].filename).to eql "invite.ics"
      expect(message.files[1].id).to eql "file-xyz-9234"
      expect(message.files[1].size).to be 1264
      expect(message.files[1].api).to be api

      # Note, messages will either be in a folder *or* labeled, not both.
      expect(message.folder.display_name).to eql "Inbox"
      expect(message.folder.name).to eql "inbox"
      expect(message.folder.id).to eql "folder-inbox"
      expect(message.folder.api).to be api

      expect(message.labels[0].display_name).to eql "Inbox"
      expect(message.labels[0].id).to eql "label-inbox"
      expect(message.labels[0].name).to eql "inbox"
      expect(message.labels[0].api).to be api

      expect(message.labels[1].display_name).to eql "All Mail"
      expect(message.labels[1].id).to eql "label-all"
      expect(message.labels[1].name).to eql "all"
      expect(message.labels[1].api).to be api
    end
  end

  describe "#save" do
    context "when `labels` key exists" do
      it "removes `labels` from the payload" do
        api = instance_double(Nylas::API, execute: JSON.parse("{}"))
        data = {
          id: "message-1234",
          labels: [
            { display_name: "All Mail", id: "label-all", name: "all" }
          ]
        }

        message = described_class.from_json(
          JSON.dump(data),
          api: api
        )

        message.save

        expect(api).to have_received(:execute).with(
          method: :put, path: "/messages/message-1234",
          payload: JSON.dump(
            id: "message-1234"
          )
        )
      end
    end
  end

  describe "#update" do
    it "let's you set the starred, unread, folder, and label ids" do
      api = instance_double(Nylas::API, execute: JSON.parse("{}"))
      message = described_class.from_json('{ "id": "message-1234" }', api: api)

      message.update(
        starred: true,
        unread: false,
        folder_id: "folder-1234",
        label_ids: %w[label-1234 label-4567]
      )

      expect(api).to have_received(:execute).with(
        method: :put, path: "/messages/message-1234",
        payload: JSON.dump(
          starred: true, unread: false,
          folder_id: "folder-1234",
          label_ids: %w[
            label-1234
            label-4567
          ]
        )
      )
    end

    it "raises an argument error if the data has any keys that aren't allowed to be updated" do
      api = instance_double(Nylas::API, execute: "{}")
      message = described_class.from_json('{ "id": "message-1234" }', api: api)
      expect do
        message.update(subject: "A new subject!")
      end.to raise_error ArgumentError, "Only #{described_class::UPDATABLE_ATTRIBUTES} are allowed to be sent"
    end
  end

  describe "update_folder" do
    it "moves message to new `folder`" do
      folder_id = "9999"
      api = instance_double(Nylas::API, execute: "{}")
      message = described_class.from_json('{ "id": "message-1234" }', api: api)
      allow(api).to receive(:execute)

      message.update_folder(folder_id)

      expect(api).to have_received(:execute).with(
        method: :put,
        path: "/messages/message-1234",
        payload: { folder_id: folder_id }.to_json
      )
    end
  end

  describe "#expanded" do
    it "fetch or return expanded version of message" do
      api = instance_double(Nylas::API, execute: "{}")
      message = described_class.from_json('{ "id": "message-1234" }', api: api)
      data = { id: "draft-1234",
               headers: { "In-Reply-To": "<evh5uy0shhpm5d0le89goor17-0@example.com>",
                          "Message-Id": "<84umizq7c4jtrew491brpa6iu-0@example.com>",
                          "References": ["<evh5uy0shhpm5d0le89goor17-0@example.com>"] } }

      allow(api).to receive(:execute).with(method: :get,
                                           path: "/messages/message-1234",
                                           query: { view: "expanded" })
                                     .and_return(data)
      message.expanded

      expect(message.expanded.headers.in_reply_to).to eql "<evh5uy0shhpm5d0le89goor17-0@example.com>"
      expect(message.expanded.headers.message_id).to eql "<84umizq7c4jtrew491brpa6iu-0@example.com>"
      expect(message.expanded.headers.references[0]).to eql "<evh5uy0shhpm5d0le89goor17-0@example.com>"
    end
  end
end
