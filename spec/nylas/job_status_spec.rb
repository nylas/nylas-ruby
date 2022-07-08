# frozen_string_literal: true

describe Nylas::JobStatus do
  it "is not creatable" do
    expect(described_class).not_to be_creatable
  end

  it "is not filterable" do
    expect(described_class).not_to be_filterable
  end

  it "is not be_updatable" do
    expect(described_class).not_to be_updatable
  end

  it "is not destroyable" do
    expect(described_class).not_to be_destroyable
  end

  it "is not showable" do
    expect(described_class).not_to be_showable
  end

  it "is listable" do
    expect(described_class).to be_listable
  end

  describe "#from_json" do
    it "deserializes all the attributes successfully" do
      json = JSON.dump(
        account_id: "test_account_id",
        action: "save_draft",
        created_at: 1622846160,
        id: "test_id",
        job_status_id: "test_job_status_id",
        object: "message",
        status: "successful",
        metadata: {
          message_id: "nylas_message_id"
        }
      )
      job_status = described_class.from_json(json, api: nil)
      expect(job_status.id).to eql "test_id"
      expect(job_status.account_id).to eql "test_account_id"
      expect(job_status.job_status_id).to eql "test_job_status_id"
      expect(job_status.action).to eql "save_draft"
      expect(job_status.created_at).to eql(Time.at(1622846160))
      expect(job_status.object).to eql "message"
      expect(job_status.status).to eql "successful"
      expect(job_status.metadata).to eq(message_id: "nylas_message_id")
    end
  end

  describe "#successful?" do
    it "returns true when status == successful" do
      json = JSON.dump(
        account_id: "test_account_id",
        action: "save_draft",
        created_at: 1622846160,
        id: "test_id",
        job_status_id: "test_job_status_id",
        object: "message",
        status: "successful"
      )
      job_status = described_class.from_json(json, api: nil)
      expect(job_status.successful?).is_a? TrueClass
    end

    it "returns false when status != successful" do
      json = JSON.dump(
        account_id: "test_account_id",
        action: "save_draft",
        created_at: 1622846160,
        id: "test_id",
        job_status_id: "test_job_status_id",
        object: "message",
        status: "failed"
      )
      job_status = described_class.from_json(json, api: nil)
      expect(job_status.successful?).is_a? FalseClass
    end
  end
end
