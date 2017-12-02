module Nylas
  module V2
    class Query
      attr_accessor :model, :api, :scope, :constraints
      def initialize(model: , api: , constraints: nil)
        self.constraints = Constraints.from_constraints(constraints)
        self.model = model
        self.api = api
        self.scope
      end

      def where(filters)
        Query.new(model: model, api: api, constraints: constraints.merge(where: filters))
      end

      def count
        Query.new(model: model, api: api, constraints: constraints.merge(view: "count")).execute[:count]
      end

      # Iterates over a single page of results based upon current pagination settings
      def each(&block)
        return enum_for(:each) unless block_given?
        execute.each do |result|
          yield(model.new(result))
        end
      end

      def limit(quantity)
        Query.new(model: model, api: api, constraints: constraints.merge(limit: quantity))
      end

      def offset(start)
        Query.new(model: model, api: api, constraints: constraints.merge(offset: start))
      end

      # Iterates over every result, retrieving a page at a time
      def find_each
        return enum_for(:find_each) unless block_given?
      end

      # Retrieves a record. Nylas doesn't support where filters on GET so this will not take into
      # consideration other query constraints, such as where clauses.
      def find(id)
        Query.new(model: model, api: api, constraints: constraints.merge(id: id)).execute.first
      end

      def to_be_executed
        { method: :get, path: model.resources_path, query: constraints.to_query }
      end

      def execute
        api.execute(to_be_executed)
      end
    end
  end
end

