# frozen_string_literal: true

require "spec_helper"
require "date"

describe Nylas::Outbox do
  let(:api) { instance_double(Nylas::API) }
  let(:outbox) { described_class.new(api: api) }
  let(:tomorrow) { Date.today + 1 }
  let(:day_after) { Date.today + 2 }

  before do
    allow(api).to receive(:execute).and_return({})
  end

  describe "standard operations" do
    let(:draft) do
      Nylas::Draft.new(to: [{ email: "not-a-real-email@example.com", name: "Example" }],
                       subject: "A new draft!",
                       metadata: { sdk: "Ruby SDK" })
    end

    it "sends a POST request on send" do
      outbox.send(draft, send_at: tomorrow.to_time.to_i, retry_limit_datetime: day_after.to_time.to_i)

      expect(api).to have_received(:execute).with(
        method: :post,
        path: "/v2/outbox",
        payload: {
          to: [{ email: "not-a-real-email@example.com", name: "Example" }],
          subject: "A new draft!",
          metadata: { sdk: "Ruby SDK" },
          send_at: tomorrow.to_time.to_i,
          retry_limit_datetime: day_after.to_time.to_i
        }.to_json
      )
    end

    it "sends a PATCH request on update" do
      draft.subject = "Updated subject"
      outbox.update("job-status-id",
                    message: draft,
                    send_at: tomorrow.to_time.to_i,
                    retry_limit_datetime: day_after.to_time.to_i)

      expect(api).to have_received(:execute).with(
        method: :patch,
        path: "/v2/outbox/job-status-id",
        payload: {
          to: [{ email: "not-a-real-email@example.com", name: "Example" }],
          subject: "Updated subject",
          metadata: { sdk: "Ruby SDK" },
          send_at: tomorrow.to_time.to_i,
          retry_limit_datetime: day_after.to_time.to_i
        }.to_json
      )
    end

    it "sends a DELETE request on delete" do
      outbox.delete("job-status-id")

      expect(api).to have_received(:execute).with(
        method: :delete,
        path: "/v2/outbox/job-status-id"
      )
    end
  end

  describe "sendgrid" do
    it "sends a GET request on sendgrid verification status" do
      data = {
        domain_verified: true,
        sender_verified: true
      }
      allow(api).to receive(:execute).and_return({ results: data })
      outbox.send_grid_verification_status

      expect(api).to have_received(:execute).with(
        method: :get,
        path: "/v2/outbox/onboard/verified_status"
      )
    end

    it "sends a DELETE request on sendgrid delete user" do
      outbox.delete_send_grid_sub_user("not-a-real-email@example.com")

      expect(api).to have_received(:execute).with(
        method: :delete,
        path: "/v2/outbox/onboard/subuser",
        payload: {
          email: "not-a-real-email@example.com"
        }.to_json
      )
    end
  end

  describe "date validation" do
    let(:epoch1990) { 636309514 }

    it "throws an error when sendAt to older than today" do
      expect { outbox.update("id", send_at: epoch1990) }.to raise_error(ArgumentError)
    end

    it "throws an error when retryLimitDatetime to older than sendAt" do
      expect do
        outbox.update("id", send_at: day_after.to_time.to_i, retry_limit_datetime: tomorrow.to_time.to_i)
      end.to raise_error(ArgumentError)
    end

    it "throws an error when retryLimitDatetime to older than today without sendAt date" do
      expect { outbox.update("id", retry_limit_datetime: epoch1990) }.to raise_error(ArgumentError)
    end
  end
end
