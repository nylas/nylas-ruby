# frozen_string_literal: true

module Nylas
  # Methods to check and raise error if extra attributes are present
  class FilterAttributes
    def initialize(attributes:, allowed_attributes:)
      @attributes = attributes
      @allowed_attributes = allowed_attributes
    end

    def check
      return if extra_attributes.empty?

      raise ArgumentError, "Only #{allowed_attributes} are allowed to be sent"
    end

    private

    attr_reader :attributes, :allowed_attributes

    def extra_attributes
      attributes - allowed_attributes
    end
  end
end
