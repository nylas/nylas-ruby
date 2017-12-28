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
end
