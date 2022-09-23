# frozen_string_literal: true

describe Nylas::When do
  describe "valid" do
    it "throws if a timezone is set to a non-IANA string" do
      when_obj = described_class.new(timezone: "Non IANA")
      error_msg = "The timezone provided (Non IANA) is not a valid IANA timezone database name"

      expect { when_obj.valid? }.to raise_error(ArgumentError, error_msg)
    end

    it "throws if a start_timezone is set to a non-IANA string" do
      when_obj = described_class.new(start_timezone: "Non IANA")
      error_msg = "The timezone provided (Non IANA) is not a valid IANA timezone database name"

      expect { when_obj.valid? }.to raise_error(ArgumentError, error_msg)
    end

    it "throws if a end_timezone is set to a non-IANA string" do
      when_obj = described_class.new(end_timezone: "Non IANA")
      error_msg = "The timezone provided (Non IANA) is not a valid IANA timezone database name"

      expect { when_obj.valid? }.to raise_error(ArgumentError, error_msg)
    end

    it "does not throw if timezone is set validly (IANA string)" do
      when_obj = described_class.new(timezone: "America/New_York")

      expect { when_obj.valid? }.not_to raise_error
    end

    it "does not throw if no timezone set" do
      when_obj = described_class.new

      expect { when_obj.valid? }.not_to raise_error
    end
  end
end
