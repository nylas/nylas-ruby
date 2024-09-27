# frozen_string_literal: true

module Nylas::V2
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
      message.merge!(validate_set_date_time(send_at, retry_limit_datetime))
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
    # @param message [Draft, OutboxMessage] The message object with updated values
    # @param send_at [Numeric] The date and time to send the message. If not set, Outbox will send this message immediately.
    # @param retry_limit_datetime [Numeric] The date and time to stop retry attempts for a message. If not set, it defaults to 24 hours after send_at.
    # @return [OutboxJobStatus] The updated outbox job status status and message data
    # rubocop:enable Layout/LineLength
    def update(job_status_id, message: nil, send_at: nil, retry_limit_datetime: nil)
      payload = {}
      payload.merge!(message.to_h(enforce_read_only: true)) if message
      payload.merge!(validate_set_date_time(send_at, retry_limit_datetime))
      outbox_response = api.execute(
        method: :patch,
        path: "#{outbox_path}/#{job_status_id}",
        payload: JSON.dump(payload)
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

    private

    def validate_set_date_time(send_at, retry_limit_datetime)
      hash = {}
      hash[:send_at] = validate_send_at(send_at) if send_at
      if retry_limit_datetime
        hash[:retry_limit_datetime] = validate_retry_limit_datetime(send_at, retry_limit_datetime)
      end

      hash
    end

    def validate_send_at(send_at)
      return send_at unless send_at != 0 && (send_at < Time.now.to_i)

      raise ArgumentError, "Cannot set message to be sent at a time before the current time."
    end

    def validate_retry_limit_datetime(send_at, retry_limit_datetime)
      valid_send_at = send_at && send_at != 0 ? send_at : Time.now.to_i
      return retry_limit_datetime unless retry_limit_datetime != 0 && (retry_limit_datetime < valid_send_at)

      raise ArgumentError, "Cannot set message to stop retrying before time to send at."
    end
  end
end
