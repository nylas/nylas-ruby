require 'spec_helper'
require 'nylas/model_state'

describe Nylas::ModelState do
  describe "#[]=" do
    it "Marks parameters as dirty when they have been changed" do
      model_state = described_class.new(some_param: "a value")
      model_state[:some_param] = "I changed"
      expect(model_state.changed_attributes[:some_param]).to eq "a value"
      expect(model_state.as_json[:some_param]).to eq "I changed"
    end
  end

  describe "#[]" do
    it "responds with new data if it's been changed" do
      model_state = described_class.new(some_param: "a value")
      model_state[:some_param] = "I changed"
      expect(model_state[:some_param]).to eq "I changed"
    end

    it "responds with starting data if it hasn't been changed" do
      model_state = described_class.new(some_param: "a value")
      expect(model_state[:some_param]).to eq "a value"
    end

    it "successfully navigates setting new values to falsey values" do

      model_state = described_class.new(some_param: "a value")
      model_state[:some_param] = nil
      expect(model_state[:some_param]).to eq nil
    end
  end

  describe "#as_json" do
    it "returns only the data for parameters that have changed" do
      model_state = described_class.new(param_a: "initial value a", param_b: "initial value b")

      model_state[:param_a] = "changed value a"

      expect(model_state.as_json).to eq({ param_a: "changed value a" })
    end

    it "calls as_json on values if they respond to as_json" do
      fake_collection = double(:fake_collection, as_json: ["an", "object", "that", "responds", "to", "as_json"])
      model_state = described_class.new(param_a: "initial value a", param_b: "initial value b")

      model_state[:param_a] = fake_collection

      expect(model_state.as_json).to eq({ param_a: fake_collection.as_json })
    end

    it "supports `options` with an `except` filter" do
      model_state = described_class.new(param_a: "initial value a", param_b: "initial value b")

      model_state[:param_a] = "change a"
      model_state[:param_b] = "change b"

      expect(model_state.as_json(except: [:param_b])).to eq(param_a: "change a")
    end
  end
end
