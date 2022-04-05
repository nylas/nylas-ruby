# frozen_string_literal: true

require "spec_helper"

describe Nylas::SendGridVerifiedStatus do
  it "Deserializes all the attributes into Ruby objects" do
    data = { domain_verified: true, sender_verified: true }

    send_grid_verified_status = described_class.new(**data)
    expect(send_grid_verified_status.domain_verified).to be true
    expect(send_grid_verified_status.sender_verified).to be true
  end
end
