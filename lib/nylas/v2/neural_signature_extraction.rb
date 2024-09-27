# frozen_string_literal: true

module Nylas::V2
  # Structure to represent a the Signature Extraction Schema.
  # @see https://developer.nylas.com/docs/intelligence/signature-extraction/#signature-feedback-response
  class NeuralSignatureExtraction < Message
    include Model
    self.resources_path = "/neural/signature"

    attribute :signature, :string
    attribute :model_version, :string
    attribute :contacts, :neural_signature_contact

    inherit_attributes

    transfer :api, to: %i[contacts]
  end
end
