module Nylas
  module V2
    module Model
      class ListAttributeDefinition
        attr_accessor :type, :exclude_when

        def initialize(type:, exclude_when:)
          self.type = type
          self.exclude_when = exclude_when
        end

        def cast(list)
          return [] if list.nil? || list.empty?
          list.map { |item| Types.registry[type].cast(item) }
        end
      end
    end
  end
end
