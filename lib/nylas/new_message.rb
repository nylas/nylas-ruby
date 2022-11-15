# frozen_string_literal: true

module Nylas
  # Data structure for sending a message via the Nylas API
  class NewMessage
    include Model
    self.creatable = false
    self.showable = false
    self.listable = false
    self.filterable = false
    self.updatable = false
    self.destroyable = false

    has_n_of_attribute :to, :email_address
    has_n_of_attribute :from, :email_address
    has_n_of_attribute :cc, :email_address
    has_n_of_attribute :bcc, :email_address
    has_n_of_attribute :reply_to, :email_address

    attribute :subject, :string
    attribute :body, :string
    attribute :reply_to_message_id, :string
    attribute :metadata, :hash
    has_n_of_attribute :sendnow, :boolean

    has_n_of_attribute :file_ids, :string

    attribute :tracking, :message_tracking

    # Sends the new message
    # @return [Message] The sent message
    # @raise [RuntimeError] if the API response data was not a hash
    def send!
      query = sendnow ? { sendnow: sendnow } : {}
      message_data = api.execute(method: :post, path: "/send", payload: to_json, query: query)
      raise "Unexpected response from the server, data received not a Message" unless message_data.is_a?(Hash)

      Message.from_hash(message_data, api: api)
    end
  end
end
