# frozen_string_literal: true

module Nylas
  module Model
    # Define a particular attribute for a given model
    class AttributeDefinition
      extend Forwardable
      def_delegators :type, :cast, :serialize
      attr_accessor :type_name, :read_only, :default

      def initialize(type_name:, read_only:, default:)
        self.type_name = type_name
        self.read_only = read_only
        self.default = default
      end

      private

      def type
        Types.registry[type_name]
      end
    end
  end
end
