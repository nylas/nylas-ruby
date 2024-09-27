# frozen_string_literal: true

module Nylas::V2
  # Ruby representation of a Nylas Job Status object
  # @see https://developer.nylas.com/docs/api/#tag--Job-Status
  class JobStatus
    include Model
    self.resources_path = "/job-statuses"
    self.listable = true

    attribute :id, :string, read_only: true
    attribute :account_id, :string, read_only: true
    attribute :job_status_id, :string, read_only: true
    attribute :action, :string, read_only: true
    attribute :object, :string, read_only: true
    attribute :status, :string, read_only: true
    attribute :created_at, :unix_timestamp, read_only: true
    attribute :reason, :string, read_only: true
    attribute :metadata, :hash, read_only: true

    # Returns the status of a job as a boolean
    # @return [Boolean] If the job was successful
    def successful?
      status == "successful"
    end
  end
end
