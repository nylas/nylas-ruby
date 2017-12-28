describe Nylas::Deltas do
  it "safely inflates an account.running event" do
    data = { "deltas": [{ "date": 1_514_335_663, "object": "account", "type": "account.running",
                          "object_data": { "namespace_id": "acc-2345", "account_id": "acc-2345",
                                           "object": "account", "attributes": nil, "id": "dlt-09876",
                                           "metadata": nil } }] }
    deltas = described_class.new(data)
    expect(deltas.length).to be 1
    delta = deltas.first
    expect(delta.date).to eql(Time.at(1_514_335_663))
    expect(delta.type).to eql "account.running"
    expect(delta.object).to eql "account"
    expect(delta.instance).to be_a Nylas::Account
    expect(delta.id).to eql "dlt-09876"
    expect(delta.namespace_id).to eql "acc-2345"
    expect(delta.account_id).to eql "acc-2345"
    expect(delta.metadata).to be_nil
    expect(delta.object_attributes).to be_nil
  end

  it "savely inflates a message.created event" do
    data = { "deltas": [{ "date": 1_514_339_684, "object": "message", "type": "message.created",
                          "object_data": { "namespace_id": "acc-1234", "account_id": "acc-1234",
                                           "object": "message",
                                           "attributes": { "thread_id": "thread-098",
                                                           "received_date": 1_514_339_665 },
                                           "id": "msg-1234", "metadata": nil } },
                        { "date": 1_514_339_684, "object": "message", "type": "message.created",
                          "object_data": { "namespace_id": "acc-1234", "account_id": "acc-1234",
                                           "object": "message",
                                           "attributes": { "thread_id": "thread-098",
                                                           "received_date": 1_514_339_675 },
                                           "id": "msg-2345", "metadata": nil } }] }

    deltas = described_class.new(data)
    expect(deltas.length).to be 2
    delta = deltas.first
    expect(delta.date).to eql(Time.at(1_514_339_684))
    expect(delta.object).to eql("message")
    expect(delta.instance).to be_a Nylas::Message
    expect(delta.instance.id).to eql "msg-1234"
    expect(delta.instance.thread_id).to eql "thread-098"
    expect(delta.instance.received_date).to eql Time.at(1_514_339_665)
  end
end
