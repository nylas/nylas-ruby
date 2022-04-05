# frozen_string_literal: true

module Nylas
  # Methods for Outbox functionality
  # @see https://developer.nylas.com/docs/api/#tag--Outbox
  class Outbox
    attr_accessor :api

    def initialize(api:)
      self.api = api
    end

    def outbox_path
      @outbox_path ||= "/v2/outbox"
    end

    # rubocop:disable Layout/LineLength
    # Send a message via Outbox
    # @param draft [Draft, OutboxMessage] The message to send
    # @param send_at [Numeric] The date and time to send the message. If not set, Outbox will send this message immediately.
    # @param retry_limit_datetime [Numeric] The date and time to stop retry attempts for a message. If not set, it defaults to 24 hours after send_at.
    # @return [OutboxJobStatus] The outbox job status status and message data
    # rubocop:enable Layout/LineLength
    def send(draft, send_at: nil, retry_limit_datetime: nil)
      message = draft.to_h(enforce_read_only: true)
      message[:send_at] = send_at unless send_at.nil?
      message[:retry_limit_datetime] = retry_limit_datetime unless retry_limit_datetime.nil?
      outbox_response = api.execute(
        method: :post,
        path: outbox_path,
        payload: JSON.dump(message)
      )

      OutboxJobStatus.new(**outbox_response)
    end

    # rubocop:disable Layout/LineLength
    # Update a scheduled Outbox message
    # @param job_status_id [String] The ID of the outbox job status
    # @param draft [Draft, OutboxMessage] The message object with updated values
    # @param send_at [Numeric] The date and time to send the message. If not set, Outbox will send this message immediately.
    # @param retry_limit_datetime [Numeric] The date and time to stop retry attempts for a message. If not set, it defaults to 24 hours after send_at.
    # @return [OutboxJobStatus] The updated outbox job status status and message data
    # rubocop:enable Layout/LineLength
    def update(job_status_id, draft, send_at: nil, retry_limit_datetime: nil)
      message = draft.to_h(enforce_read_only: true)
      message[:send_at] = send_at unless send_at.nil?
      message[:retry_limit_datetime] = retry_limit_datetime unless retry_limit_datetime.nil?
      outbox_response = api.execute(
        method: :patch,
        path: "#{outbox_path}/#{job_status_id}",
        payload: JSON.dump(message)
      )

      OutboxJobStatus.new(**outbox_response)
    end

    # Delete a scheduled Outbox message
    # @param job_status_id [String] The ID of the outbox job status to delete
    # @return [void]
    def delete(job_status_id)
      api.execute(
        method: :delete,
        path: "#{outbox_path}/#{job_status_id}"
      )
    end

    # SendGrid - Check Authentication and Verification Status
    # @return [SendGridVerifiedStatus] The SendGrid Authentication and Verification Status
    def send_grid_verification_status
      response = api.execute(
        method: :get,
        path: "#{outbox_path}/onboard/verified_status"
      )

      raise "Verification status not present in response" if response.key?("results")

      SendGridVerifiedStatus.new(**response[:results])
    end

    # SendGrid -  Delete SendGrid Subuser and UAS Grant
    # @param email [String] Email address for SendGrid subuser to delete
    # @return [void]
    def delete_send_grid_sub_user(email)
      api.execute(
        method: :delete,
        path: "#{outbox_path}/onboard/subuser",
        payload: JSON.dump({ email: email })
      )
    end
  end
end

