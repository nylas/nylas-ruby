module Nylas
  # Structure to represent the Folder Schema
  # @see https://docs.nylas.com/reference#folders
  class Folder
    include Model
    self.resources_path = "/folders"
    self.creatable = true
    self.listable = true
    self.showable = true
    self.filterable = false
    self.updatable = true
    self.destroyable = true

    attribute :id, :string
    attribute :account_id, :string

    attribute :object, :string

    attribute :name, :string
    attribute :display_name, :string
  end

  # Serializes, Deserializes between {Folder} objects and a {Hash}
  class FolderType < Types::HashType
    casts_to Folder
  end
end
