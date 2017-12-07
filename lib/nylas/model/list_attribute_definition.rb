module Nylas
  module Model
    class ListAttributeDefinition
      attr_accessor :type_name, :exclude_when

      def initialize(type_name:, exclude_when:)
        self.type_name = type_name
        self.exclude_when = exclude_when
      end

      def cast(list)
        return [] if list.nil? || list.empty?
        list.map { |item| type.cast(item) }
      end

      def serialize(list)
        return [] if list.nil? || list.empty?
        list.map { |item| type.serialize(item) }
      end


      def type
        Types.registry[type_name]
      end
    end
  end
end
