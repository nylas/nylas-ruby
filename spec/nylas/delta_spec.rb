# frozen_string_literal: true

describe Nylas::Delta do
  it "initialize data" do
    data = {
      object: "message",
      account_id: "acc-id",
      id: "message-id",
      type: "message",
      event: "created",
      cursor: "999",
      namespace_id: "namespace-id",
      date: 1_609_439_400,
      metadata: { key: :value },
      object_attributes: { object: :attributes }
    }

    delta = described_class.new(**data)

    expect(delta.object).to eq("message")
    expect(delta.account_id).to eq("acc-id")
    expect(delta.id).to eq("message-id")
    expect(delta.type).to eq("message")
    expect(delta.event).to eq("created")
    expect(delta.cursor).to eq("999")
    expect(delta.namespace_id).to eq("namespace-id")
    expect(delta.date).to eq(Time.at(1_609_439_400))
    expect(delta.metadata).to eq(key: :value)
    expect(delta.object_attributes).to eq(object: :attributes)
  end

  describe "#model" do
    it "returns model based on given `object`" do
      data = {
        object: "message"
      }

      delta = described_class.new(**data)

      expect(delta.model).to be_a(Nylas::Message)
    end

    it "returns `nil` if `object` is nil" do
      data = {
        type: "message"
      }

      delta = described_class.new(**data)

      expect(delta.model).to eq(nil)
    end
  end
end
