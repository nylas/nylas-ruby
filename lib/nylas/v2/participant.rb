# frozen_string_literal: true

module Nylas::V2
  # Structure to represent the Participant
  class Participant
    include Model::Attributable
    attribute :name, :string
    attribute :email, :string
    attribute :phone_number, :string
    attribute :comment, :string
    attribute :status, :string, read_only: true
  end
end
