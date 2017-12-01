module Nylas
  module V2
    module Model
      class AttributeDefinition
        extend Forwardable
        def_delegators :type, :cast, :serialize
        attr_accessor :type_name, :exclude_when
        def initialize(type_name:, exclude_when:)
          self.type_name = type_name
          self.exclude_when = exclude_when
        end

        private def type
          Types.registry[type_name]
        end
      end
    end
  end
end
