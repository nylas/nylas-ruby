module Nylas
  module V2
    class Constraints
      def initialize(where: nil, limit: nil, offset: nil)
        self.where = where
        self.limit = limit
        self.offset = offset
      end

      def self.from_constraints
      end
    end
  end
end
