module Nylas
  # Structure to represent the Label Schema
  # @see https://docs.nylas.com/reference#labels
  class Label
    include Model
    self.resources_path = "/labels"
    self.searchable = false

    attribute :id, :string
    attribute :account_id, :string

    attribute :object, :string

    attribute :name, :string
    attribute :display_name, :string
  end

  # Serializes, Deserializes between {Label} objects and a Hash
  class LabelType < Types::HashType
    casts_to Label
  end
end
