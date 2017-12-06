module Nylas
  module V2
    module Model
      class AttributeDefinition
        extend Forwardable
        def_delegators :type, :cast, :serialize
        attr_accessor :type_name, :exclude_when, :default
        def initialize(type_name:, exclude_when:, default: )
          self.type_name = type_name
          self.exclude_when = exclude_when
          self.default = default
        end

        private def type
          Types.registry[type_name]
        end
      end
    end
  end
end
