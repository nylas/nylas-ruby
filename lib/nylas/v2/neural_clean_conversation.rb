# frozen_string_literal: true

module Nylas::V2
  # Structure to represent a the Neural Clean Conversations object.
  # @see https://developer.nylas.com/docs/intelligence/clean-conversations/#clean-conversation-response
  class NeuralCleanConversation < Message
    include Model
    self.resources_path = "/neural/conversation"
    self.listable = true
    IMAGE_REGEX = /[(']cid:(.*?)[)']/.freeze

    attribute :conversation, :string
    attribute :model_version, :string

    inherit_attributes

    # Parses image file IDs found in the clean conversation object and returns
    # an array of File objects returned from the File API
    def extract_images
      return if conversation.nil?

      files = []
      matches = conversation.scan(IMAGE_REGEX)
      matches.each do |match|
        # After applying the regex, if there are IDs found they would be
        # in the form of => 'cid:xxxx' (including apostrophes), so we discard
        # everything before and after the file ID (denoted as xxxx above)
        files.push(api.files.find(match))
      end
      files
    end
  end
end
