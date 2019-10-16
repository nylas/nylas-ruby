# frozen_string_literal: true

describe Nylas::FilterAttributes do
  describe "#check" do
    context "when `attributes` and `allowed_attributes` are similar" do
      it "does not raise any error" do
        attributes = %i[foo bar]
        allowed_attributes = %i[foo bar]
        filter = described_class.new(attributes: attributes, allowed_attributes: allowed_attributes)

        expect { filter.check }.not_to raise_error
      end
    end

    context "when `attributes` and `allowed_attributes` are different" do
      it "raises an error" do
        attributes = %i[foo bar]
        allowed_attributes = %i[foo]
        filter = described_class.new(attributes: attributes, allowed_attributes: allowed_attributes)

        expect { filter.check }.to raise_error(ArgumentError, "Only [:foo] are allowed to be sent")
      end
    end
  end
end
