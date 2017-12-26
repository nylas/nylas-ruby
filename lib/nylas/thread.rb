module Nylas
  # Ruby representation of the Nylas /threads API
  # @see https://docs.nylas.com/reference#threads
  class Thread
    include Model
    self.filterable = true
    self.listable = true
    self.updatable = true

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
    has_n_of_attribute :participants, :participant
    attribute :snippet, :string
    attribute :starred, :boolean
    attribute :subject, :string
    attribute :unread, :boolean
    attribute :version, :integer
    attribute :folder_id, :string

    has_n_of_attribute :label_ids, :string

    UPDATABLE_ATTRIBUTES = %i[label_ids folder_id starred unread].freeze
    def update(data)
      unupdatable_attributes = data.keys.reject { |name| UPDATABLE_ATTRIBUTES.include?(name) }
      unless unupdatable_attributes.empty?
        raise ArgumentError, "Cannot update #{unupdatable_attributes} only " \
                             "#{UPDATABLE_ATTRIBUTES} are updatable"
      end
      super(data)
    end

    def starred?
      starred
    end

    def unread?
      unread
    end
  end
end
