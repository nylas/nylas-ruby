module Nylas
  # Structure to represent a the File Schema.
  # @see https://docs.nylas.com/reference#events
  class File
    include Model::Attributable
    attribute :id, :string
    attribute :content_type, :string
    attribute :filename, :string
    attribute :size, :integer
  end

  # Serializes, Deserializes between {File} objects and a {Hash}
  class FileType < Types::HashType
    casts_to File
  end
end
