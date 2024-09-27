# frozen_string_literal: true

module Nylas::V2
  module Model
    # Allows models to have an attribute which is a lists of another type of thing
    class ListAttributeDefinition
      attr_accessor :type_name, :read_only, :default

      def initialize(type_name:, read_only:, default:)
        self.type_name = type_name
        self.read_only = read_only
        self.default = default
      end

      def cast(list)
        return default if list.nil? || list.empty?

        list.map { |item| type.cast(item) }
      end

      def serialize(list, enforce_read_only: false)
        list = default if list.nil? || list.empty?
        if enforce_read_only
          list.map { |item| type.serialize_for_api(item) }
        else
          list.map { |item| type.serialize(item) }
        end
      end

      def serialize_for_api(list)
        serialize(list, enforce_read_only: true)
      end

      def type
        Types.registry[type_name]
      end
    end
  end
end
