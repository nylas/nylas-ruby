module Nylas
  # Structure to represent the Contact Group schema
  # @see https://docs.nylas.com/reference#contactsid
  class ContactGroup
    include Model::Attributable
    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    attribute :name, :string
    attribute :path, :string
  end
end
