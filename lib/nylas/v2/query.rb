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
        execute(query: { view: "count" })
      end

      # Iterates over a single page of results based upon current pagination settings
      def each(&block)
        return enum_for(:each) unless block_given?
        execute.each(&block)
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
        Query.new(model: model, api: api, constraints: constraints.merge(id: id)).execute
      end

      def execute(action: :list)
        case action
        when :show
          api.get(model.show_path(constraints.id))
        when :list
          raise NotImplementedError "Implement :list!"
        when :create
          raise NotImplementedError "Implement :create!"
        when :update
          raise NotImplementedError "Implement :update!"
        when :destroy
          raise NotImplementedError "Implement :destroy!"
        end
      end
    end
  end
end

