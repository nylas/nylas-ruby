# frozen_string_literal: true

module Nylas
  # Structure to represent the "Name" object in the Neural API's Signature Extraction Contact object
  # @see https://developer.nylas.com/docs/intelligence/signature-extraction/#parse-signature-response
  class NeuralContactName
    include Model::Attributable
    attribute :first_name, :string
    attribute :last_name, :string
  end
end
