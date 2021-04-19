# frozen_string_literal: true

module Nylas
  # Special collection for delta objects
  class DeltasCollection < Collection
    attr_accessor :deltas

    extend Forwardable
    def_delegators :execute, :cursor_start, :cursor_end,
                   :count, :each, :to_h, :to_a, :empty?

    def initialize(api:, constraints: nil, model: Deltas)
      super(api: api, model: model, constraints: constraints)
    end

    def latest_cursor
      api.execute(method: :post, path: "#{resources_path}/latest_cursor")[:cursor]
    end

    def latest
      since(latest_cursor)
    end

    def since(cursor)
      where(cursor: cursor)
    end

    def next_page(*)
      return nil if empty?

      where(cursor: cursor_end)
    end

    # Retrieves the data from the API for the particular constraints
    # @return [Detlas]
    def execute
      self.deltas ||= Deltas.new(**api.execute(**to_be_executed))
    end
  end
end
