# frozen_string_literal: true

describe Nylas::Deltas do
  # Inflate an account.running event.
  it "safely inflates an account.running event" do
    data = {
      "deltas": [
        {
          "date": 1_514_335_663,
          "object": "account",
          "type": "account.running",
          "object_data": {
            "namespace_id": "acc-2345",
            "account_id": "acc-2345",
            "object": "account",
            "attributes": nil,
            "id": "dlt-09876",
            "metadata": nil
          }
        }
      ]
    }

    deltas = described_class.new(**data)

    expect(deltas.length).to be 1
    delta = deltas.first
    expect(delta.date).to eql(Time.at(1_514_335_663))
    expect(delta.type).to eql "account.running"
    expect(delta.object).to eql "account"
    expect(delta.model).to be_a Nylas::Account
    expect(delta.id).to eql "dlt-09876"
    expect(delta.namespace_id).to eql "acc-2345"
    expect(delta.account_id).to eql "acc-2345"
    expect(delta.metadata).to be_nil
    expect(delta.object_attributes).to be_nil
  end

  # Inflate a message.created event.
  it "savely inflates a message.created event" do
    data = {
      "deltas": [
        {
          "date": 1_514_339_684,
          "object": "message",
          "type": "message.created",
          "object_data": {
            "namespace_id": "acc-1234",
            "account_id": "acc-1234",
            "object": "message",
            "attributes": {
              "thread_id": "thread-098",
              "received_date": 1_514_339_665
            },
            "id": "msg-1234",
            "metadata": nil
          }
        },
        {
          "date": 1_514_339_684,
          "object": "message",
          "type": "message.created",
          "object_data": {
            "namespace_id": "acc-1234",
            "account_id": "acc-1234",
            "object": "message",
            "attributes": {
              "thread_id": "thread-098",
              "received_date": 1_514_339_675
            },
            "id": "msg-2345", "metadata": nil
          }
        }
      ]
    }

    deltas = described_class.new(**data)
    expect(deltas.length).to be 2
    delta = deltas.first
    expect(delta.date).to eql(Time.at(1_514_339_684))
    expect(delta.object).to eql("message")
    expect(delta.model).to be_a Nylas::Message
    expect(delta.model.id).to eql "msg-1234"
    expect(delta.model.thread_id).to eql "thread-098"
    expect(delta.model.received_date).to eql Time.at(1_514_339_665)
  end

  # Parse stream data from multiple deltas.
  it "parses stream data from multiple changes" do
    data = {
      "deltas": [
        {
          "attributes": {
            "account_id": "acc-id",
            "object": "message",
            "id": "message-id",
            headers:
            {
              "In-Reply-To": "<evh5uy0shhpm5d0le89goor17-0@example.com>",
              "Message-Id": "<84umizq7c4jtrew491brpa6iu-0@example.com>",
              References: ["<evh5uy0shhpm5d0le89goor17-0@example.com>"]
            }
          }
        },
        {
          "attributes": {
            "account_id": "acc-id",
            "object": "event",
            "id": "event-id"
          }
        }
      ]
    }

    deltas = described_class.new(**data)

    expect(deltas.count).to eq(2)
    message_delta = deltas.first
    expect(message_delta.object).to eq("message")
    expect(message_delta.object_attributes).to include(
      account_id: "acc-id",
      object: "message",
      id: "message-id",
      headers: {
        "In-Reply-To": "<evh5uy0shhpm5d0le89goor17-0@example.com>",
        "Message-Id": "<84umizq7c4jtrew491brpa6iu-0@example.com>",
        References: ["<evh5uy0shhpm5d0le89goor17-0@example.com>"]
      }
    )
    expect(message_delta.model.attributes.to_h).to include(
      account_id: "acc-id",
      object: "message",
      id: "message-id",
      headers: {
        in_reply_to: "<evh5uy0shhpm5d0le89goor17-0@example.com>",
        message_id: "<84umizq7c4jtrew491brpa6iu-0@example.com>",
        references: ["<evh5uy0shhpm5d0le89goor17-0@example.com>"]
      }
    )
    expect(message_delta.model).to be_a(Nylas::Message)
    expect(message_delta.id).to eq("message-id")
    expect(message_delta.account_id).to eq("acc-id")
    expect(message_delta.headers.in_reply_to).to eq("<evh5uy0shhpm5d0le89goor17-0@example.com>")
    expect(message_delta.headers.message_id).to eq("<84umizq7c4jtrew491brpa6iu-0@example.com>")
    expect(message_delta.headers.references).to eq(["<evh5uy0shhpm5d0le89goor17-0@example.com>"])

    event_delta = deltas.last
    expect(event_delta.object).to eq("event")
    expect(event_delta.object_attributes).to include(
      account_id: "acc-id",
      object: "event",
      id: "event-id"
    )
    expect(event_delta.model).to be_a(Nylas::Event)
    expect(event_delta.model.attributes.to_h).to include(
      account_id: "acc-id",
      object: "event",
      id: "event-id"
    )
    expect(event_delta.id).to eq("event-id")
    expect(event_delta.account_id).to eq("acc-id")
  end

  # Parses deltas if the attributes param is nil.
  it "parses deltas if `attributes` is `nil`" do
    data = {
      "deltas": [
        {
          object: "message",
          attributes: nil
        }
      ]
    }

    deltas = described_class.new(**data)

    expect(deltas.count).to eq(1)
    delta = deltas.last
    expect(delta.model).to be_a(Nylas::Message)
    expect(delta.attributes.to_h).to eq(
      object: "message"
    )
  end

  # Parses deltas if the attributes param is not present.
  it "parses deltas if `attributes` is not present" do
    data = {
      "deltas": [
        {
          id: "some-id",
          object: "event"
        }
      ]
    }

    deltas = described_class.new(**data)

    expect(deltas.count).to eq(1)
    delta = deltas.last
    expect(delta.id).to eq("some-id")
    expect(delta.model).to be_a(Nylas::Event)
    expect(delta.attributes.to_h).to eq(
      id: "some-id",
      object: "event"
    )
  end

  # Parses deltas if the attributes param is an empty hash.
  it "parses deltas if `attributes` is empty hash" do
    data = {
      "deltas": [
        {
          id: "some-id",
          object: "message",
          attributes: {}
        }
      ]
    }

    deltas = described_class.new(**data)

    expect(deltas.count).to eq(1)
    delta = deltas.last
    expect(delta.id).to eq("some-id")
    expect(delta.model).to be_a(Nylas::Message)
    expect(delta.attributes.to_h).to eq(
      id: "some-id",
      object: "message"
    )
  end
end
