require 'spec_helper'

describe Nylas::Model do
  describe FullModel do
    def example_instance_json
      "{ }"
    end

    def example_instance_hash
      JSON.parse(example_instance_json, symbolize_names: true)
    end

    let(:api) { FakeAPI.new }

    describe "#save" do
      context ReadOnlyModel do
        it "raises a NotImplementedError exception" do
          instance = described_class.from_json(example_instance_json, api: api)
          expect { instance.save }.to raise_error(NotImplementedError, "#{described_class} is read only")
        end
      end
    end

    describe "#update" do
      context ReadOnlyModel do
        it "raises a NotImplementedError exception" do
          instance = described_class.from_json(example_instance_json, api: api)
          expect { instance.update(name: "other") }.to raise_error(NotImplementedError,
                                                                   "#{described_class} is read only")
        end
      end
    end


    describe "#where" do
      describe NonSearchableModel do
      end
    end
  end
end
