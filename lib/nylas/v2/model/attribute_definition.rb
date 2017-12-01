module Nylas
  module V2
    module Model
      class AttributeDefinition
        attr_accessor :type, :exclude_when
        def initialize(type:, exclude_when:)
          self.type = type
          self.exclude_when = exclude_when
        end

        def cast(value)
          Types.registry[type].cast(value)
        end
      end
    end
  end
end
