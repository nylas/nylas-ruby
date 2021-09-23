# frozen_string_literal: true

module Nylas
  # Class containing methods for accessing Neural API features.
  # @see https://developer.nylas.com/docs/intelligence/
  class Neural
    attr_accessor :api

    def initialize(api:)
      self.api = api
    end

    def sentiment_analysis_message(message_ids)
      body = { message_id: message_ids }
      response = request(NeuralSentimentAnalysis.resources_path, body)

      collection = []
      response.each do |sentiment|
        collection.push(NeuralSentimentAnalysis.new(**sentiment.merge(api: api)))
      end
      collection
    end

    def sentiment_analysis_text(text)
      body = { text: text }
      NeuralSentimentAnalysis.new(**request(NeuralSentimentAnalysis.resources_path, body).merge(api: api))
    end

    def extract_signature(message_ids, options = nil)
      body = { message_id: message_ids }
      body = body.merge(options) unless options.nil?
      response = request(NeuralSignatureExtraction.resources_path, body)

      collection = []
      response.each do |signature|
        collection.push(NeuralSignatureExtraction.new(**signature.merge(api: api)))
      end
      collection
    end

    def ocr_request(file_id, pages = nil)
      body = { file_id: file_id }
      body[:pages] = pages unless pages.nil?

      NeuralOcr.new(**request(NeuralOcr.resources_path, body).merge(api: api))
    end

    def categorize(message_ids)
      body = { message_id: message_ids }
      response = request(NeuralCategorizer.resources_path, body)

      collection = []
      response.each do |categorize|
        collection.push(NeuralCategorizer.new(**categorize.merge(api: api)))
      end
      collection
    end

    def clean_conversation(message_ids, options = nil)
      body = { message_id: message_ids }
      body = body.merge(delete_from_hash(options.to_hash, :parse_contact)) unless options.nil?

      response = request(NeuralCleanConversation.resources_path, body)
      collection = []
      response.each do |conversation|
        collection.push(NeuralCleanConversation.new(**conversation.merge(api: api)))
      end
      collection
    end

    private

    def request(path, body)
      api.execute(
        method: :put,
        path: path,
        payload: JSON.dump(body)
      )
    end

    # For Ruby < 3.0 support, as it doesn't support Hash.except
    def delete_from_hash(hash, to_delete)
      hash.delete(to_delete)
      hash
    end
  end
end
