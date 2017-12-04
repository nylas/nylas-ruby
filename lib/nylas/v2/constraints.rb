module Nylas
  module V2
    class Constraints
      attr_accessor :where, :limit, :offset, :view, :per_page
      def initialize(where: {}, limit: nil, offset: 0, view: nil, per_page: 100)
        self.where = where
        self.limit = limit
        self.offset = offset
        self.view = view
        self.per_page = per_page
      end

      def merge(where: {}, limit: nil, offset: nil, view: nil, per_page: nil)
        Constraints.new(where: where.merge(where),
                        limit: limit || self.limit,
                        per_page: per_page || self.per_page,
                        offset: offset || self.offset,
                        view: view || self.view)
      end

      def next_page
        merge(offset: offset + per_page)
      end

      def to_query
        query = where.reduce({}) do |query, (name, value)|
          query[name] = value
          query
        end
        query[:limit] = !limit.nil? && limit < per_page ? limit : per_page 
        query[:offset] = offset unless offset.nil?
        query[:view] = view unless view.nil?
        query
      end

      def self.from_constraints(constraints=Constraints.new)
        return constraints if constraints.is_a?(Constraints)
        return new(**constraints) if constraints.respond_to?(:key?)
        return new if constraints.nil?
        raise TypeError, "passed in constraints #{constraints} cannot be cast to a set of constraints"
      end
    end
  end
end
