# frozen_string_literal: true

module Nylas
  # Structure to represent the "Link" object in the Neural API's Signature Extraction Contact object
  # @see https://developer.nylas.com/docs/intelligence/signature-extraction/#parse-signature-response
  class NeuralContactLink
    include Model::Attributable
    attribute :description, :string
    attribute :url, :string
  end
end
