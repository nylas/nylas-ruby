# frozen_string_literal: true

require "spec_helper"

describe Nylas::OutboxJobStatus do
  it "Deserializes all the attributes into Ruby objects" do
    data = { job_status_id: "job-status-123", status: "pending",
             original_data: { send_at: 1649179701, retry_limit_datetime: 1649266101,
                              original_send_at: 1649179701, account_id: "acc-9987",
                              to: [{ email: "to@example.com", name: "To Example" }],
                              from: [{ email: "from@example.com", name: "From Example" }],
                              subject: "A draft emails subject",
                              body: "<h1>A draft Email</h1>" } }

    outbox_job_status = described_class.new(**data)
    expect(outbox_job_status.job_status_id).to eql "job-status-123"
    expect(outbox_job_status.status).to eql "pending"

    expect(outbox_job_status.original_data.send_at).to eql Time.at(1649179701)
    expect(outbox_job_status.original_data.retry_limit_datetime).to eql Time.at(1649266101)
    expect(outbox_job_status.original_data.original_send_at).to eql Time.at(1649179701)
    expect(outbox_job_status.original_data.account_id).to eql "acc-9987"
    expect(outbox_job_status.original_data.to[0].email).to eql "to@example.com"
    expect(outbox_job_status.original_data.to[0].name).to eql "To Example"
    expect(outbox_job_status.original_data.from[0].email).to eql "from@example.com"
    expect(outbox_job_status.original_data.from[0].name).to eql "From Example"
    expect(outbox_job_status.original_data.subject).to eql "A draft emails subject"
    expect(outbox_job_status.original_data.body).to eql "<h1>A draft Email</h1>"
  end
end
