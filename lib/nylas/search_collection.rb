# frozen_string_literal: true

module Nylas
  # Ensures our search requests hit the right path
  class SearchCollection < Collection
    def resources_path
      "#{model.resources_path(api: api)}/search"
    end

    def count
      self.class.new(model: model, api: api, constraints: constraints).find_each.map.count
    end
  end
end
