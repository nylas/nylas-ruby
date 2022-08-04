# frozen_string_literal: true

module Nylas
  # Structure to represent a the Neural Sentiment Analysis object.
  # @see https://developer.nylas.com/docs/intelligence/sentiment-analysis/#sentiment-analysis-response-message
  class NeuralSentimentAnalysis
    include Model
    self.resources_path = "/neural/sentiment"
    self.listable = true

    attribute :account_id, :string
    attribute :sentiment, :string
    attribute :sentiment_score, :float
    attribute :processed_length, :integer
    attribute :text, :string
  end
end
