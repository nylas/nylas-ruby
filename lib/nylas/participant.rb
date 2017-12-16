module Nylas
  # Structure to represent the Participant
  class Participant
    include Model::Attributable
    attribute :name, :string
    attribute :email, :string
    attribute :comment, :string
    attribute :status, :string
  end

  # Serializes, Deserializes between {Participant} objects and a {Hash}
  class ParticipantType < Types::HashType
    casts_to Participant
  end
end
