# frozen_string_literal: true

module Nylas
  # Structure to represent a the Neural Optical Character Recognition object.
  # @see https://developer.nylas.com/docs/intelligence/optical-charecter-recognition/#ocr-response
  class NeuralMessageOptions
    attr_accessor :ignore_links, :ignore_images, :ignore_tables, :remove_conclusion_phrases,
                  :images_as_markdown, :parse_contact

    def initialize(ignore_links: nil,
                   ignore_images: nil,
                   ignore_tables: nil,
                   remove_conclusion_phrases: nil,
                   images_as_markdown: nil,
                   parse_contact: nil)
      @ignore_links = ignore_links
      @ignore_images = ignore_images
      @ignore_tables = ignore_tables
      @remove_conclusion_phrases = remove_conclusion_phrases
      @images_as_markdown = images_as_markdown
      @parse_contact = parse_contact
    end

    def to_hash
      hash = {}
      hash[:ignore_links] = @ignore_links unless @ignore_links.nil?
      hash[:ignore_images] = @ignore_images unless @ignore_images.nil?
      hash[:ignore_tables] = @ignore_tables unless @ignore_tables.nil?
      hash[:remove_conclusion_phrases] = @remove_conclusion_phrases unless @remove_conclusion_phrases.nil?
      hash[:images_as_markdown] = @images_as_markdown unless @images_as_markdown.nil?
      hash[:parse_contact] = @parse_contact unless @parse_contact.nil?
      hash
    end
  end
end
