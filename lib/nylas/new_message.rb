# frozen_string_literal: true

module Nylas
  # Data structure for seending a message via the Nylas API
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

    has_n_of_attribute :file_ids, :string

    attribute :tracking, :message_tracking

    def send!
      Message.new(api.execute(method: :post, path: "/send", payload: to_json).merge(api: api))
    end
  end
end
