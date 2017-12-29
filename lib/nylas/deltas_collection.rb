module Nylas
  # Special collection for delta objects
  class DeltasCollection < Collection
    def initialize(api:)
      super(api: api, model: Deltas)
    end

    def latest_cursor
      api.execute(method: :post, path: "#{resources_path}/latest_cursor")[:cursor]
    end

    def latest
      since(latest_cursor)
    end

    def since(cursor)
      data = api.execute(method: :get, path: resources_path, query: { cursor: cursor })
      Deltas.new(data.merge(api: api))
    end
  end
end
