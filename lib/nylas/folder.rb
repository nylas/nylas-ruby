module Nylas
  # Structure to represent the Folder Schema
  # @see https://docs.nylas.com/reference#folders
  class Folder
    include Model::Attributable
    attribute :id, :string
    attribute :name, :string
    attribute :display_name, :string
  end

  # Serializes, Deserializes between {Folder} objects and a {Hash}
  class FolderType < Types::HashType
    casts_to Folder
  end
end
