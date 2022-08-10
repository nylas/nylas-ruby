# frozen_string_literal: true

module Nylas
  # Ruby representatin of a Nylas Message object
  # @see https://docs.nylas.com/reference#messages
  class Message
    include Model
    self.raw_mime_type = "message/rfc822"
    self.resources_path = "/messages"
    self.listable = true
    self.showable = true
    self.filterable = true
    self.updatable = true
    self.searchable = true
    self.id_listable = true
    UPDATABLE_ATTRIBUTES = %i[label_ids folder_id starred unread metadata].freeze

    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    attribute :thread_id, :string

    attribute :headers, :message_headers

    has_n_of_attribute :to, :email_address
    has_n_of_attribute :from, :email_address
    has_n_of_attribute :cc, :email_address
    has_n_of_attribute :bcc, :email_address
    has_n_of_attribute :reply_to, :email_address

    attribute :date, :unix_timestamp
    # This is only used when receiving a message received notification via a webhook
    attribute :received_date, :unix_timestamp
    attribute :subject, :string
    attribute :snippet, :string
    attribute :body, :string
    attribute :starred, :boolean
    attribute :unread, :boolean

    has_n_of_attribute :events, :event
    has_n_of_attribute :files, :file
    attribute :folder, :folder
    attribute :folder_id, :string
    attribute :metadata, :hash
    attribute :reply_to_message_id, :string, read_only: true
    attribute :job_status_id, :string, read_only: true

    has_n_of_attribute :labels, :label, read_only: true
    has_n_of_attribute :label_ids, :string

    transfer :api, to: %i[events files folder labels]

    def starred?
      starred
    end

    def unread?
      unread
    end

    def update(payload)
      FilterAttributes.new(
        attributes: payload.keys,
        allowed_attributes: UPDATABLE_ATTRIBUTES
      ).check

      super(**payload)
    end

    def update_folder(folder_id)
      update(folder_id: folder_id)
    end

    def expanded
      return self unless headers.nil?

      assign(**api.execute(method: :get, path: resource_path, query: { view: "expanded" }))
      # Transfer reference to the API to attributes that need it
      transfer_attributes
      self
    end

    def save
      handle_folder

      super
    end

    def handle_folder
      return if folder.nil?

      self.folder_id = folder.id if folder_id.nil? && !self.to_h.dig(:folder, :id).nil?

      self.folder = nil
    end
  end
end
