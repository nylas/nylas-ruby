module Nylas
  # Structure to represent the Label Schema
  # @see https://docs.nylas.com/reference#labels
  class Label
    include Model::Attributable
    attribute :id, :string
    attribute :name, :string
    attribute :display_name, :string
  end

  # Serializes, Deserializes between {Label} objects and a Hash
  class LabelType < Types::HashType
    casts_to Label
  end
end
