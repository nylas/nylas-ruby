# frozen_string_literal: true

module Nylas
  # Ruby representation of the Nylas /threads API
  # @see https://docs.nylas.com/reference#threads
  class Thread
    include Model
    self.searchable = true
    self.listable = true
    self.filterable = true
    self.updatable = true
    self.id_listable = true
    self.countable = true

    self.resources_path = "/threads"

    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    has_n_of_attribute :draft_ids, :string
    attribute :first_message_timestamp, :unix_timestamp
    attribute :has_attachments, :boolean

    attribute :last_message_timestamp, :unix_timestamp
    attribute :last_message_received_timestamp, :unix_timestamp
    attribute :last_message_sent_timestamp, :unix_timestamp

    has_n_of_attribute :labels, :label
    has_n_of_attribute :folders, :folder
    has_n_of_attribute :message_ids, :string
    has_n_of_attribute :messages, :message
    has_n_of_attribute :participants, :participant
    attribute :snippet, :string
    attribute :starred, :boolean
    attribute :subject, :string
    attribute :unread, :boolean
    attribute :version, :integer
    attribute :folder_id, :string

    has_n_of_attribute :label_ids, :string

    transfer :api, to: %i[labels folders]

    UPDATABLE_ATTRIBUTES = %i[label_ids folder_id starred unread].freeze
    def update(data)
      unupdatable_attributes = data.keys.reject { |name| UPDATABLE_ATTRIBUTES.include?(name) }
      unless unupdatable_attributes.empty?
        raise ArgumentError, "Cannot update #{unupdatable_attributes} only " \
                             "#{UPDATABLE_ATTRIBUTES} are updatable"
      end
      super(**data)
    end

    def update_folder(folder_id)
      update(folder_id: folder_id)
    end

    def starred?
      starred
    end

    def unread?
      unread
    end
  end
end
