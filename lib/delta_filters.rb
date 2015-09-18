module Inbox
  class DeltaFilters

    attr_reader :filter_map

    def self.build_exclude_types(object_types)
      new.build_exclude_types(object_types)
    end

    def initialize(filter_map: API::OBJECTS_TABLE)
      @filter_map = filter_map
    end

    def build_exclude_types(object_types)
      filters = Array(object_types).map { |type| filter_map.key(type) }.compact.join(',')

      return filters if filters.empty?

      "&exclude_types=#{filters}"
    end

  end
end
