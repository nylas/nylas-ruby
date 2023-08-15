# frozen_string_literal: true

require "spec_helper"

describe Nylas::FreeBusy do
  # Set read and write values for an email message.
  describe "#email" do
    it "reads and write value for email" do
      email = "test@example.com"

      result = described_class.new(email: email)

      expect(result.email).to eq(email)
    end
  end

  # Set read and write values for an object.
  describe "#object" do
    it "reads and write value for object" do
      object = "free_busy"

      result = described_class.new(object: object)

      expect(result.object).to eq(object)
    end
  end

  # Set read and write values for time_slots.
  describe "#time_slots" do
    it "reads and write value for time_slots" do
      time_slots = [
        {
          object: "time_slot",
          status: "busy",
          start_time: 1_609_439_400,
          end_time: 1_640_975_400
        }
      ]

      result = described_class.new(time_slots: time_slots)

      expect(result.time_slots.to_a.size).to eq(1)
      time_slot = result.time_slots.last
      expect(time_slot.object).to eq("time_slot")
      expect(time_slot.status).to eq("busy")
      expect(time_slot.start_time.to_i).to eq(1_609_439_400)
      expect(time_slot.end_time.to_i).to eq(1_640_975_400)
    end
  end
end
