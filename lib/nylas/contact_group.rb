# frozen_string_literal: true

module Nylas
  # Structure to represent the Contact Group schema
  # @see https://docs.nylas.com/reference#contactsid
  class ContactGroup
    include Model
    self.resources_path = "/contacts/groups"
    self.creatable = false
    self.listable = true
    self.showable = false
    self.filterable = false
    self.updatable = false
    self.destroyable = false

    attribute :id, :string
    attribute :object, :string
    attribute :account_id, :string
    attribute :name, :string
    attribute :path, :string
  end
end
