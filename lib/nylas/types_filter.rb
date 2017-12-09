module Nylas
  class TypesFilter
    attr_accessor :filter, :types
    def initialize(filter, types: [])
      self.filter = filter
      self.types = types
    end

    def to_query_string
      return "" if types.empty?
      query_string = "&#{filter}_types="

      types.each do |value|
        count = 0
        if OBJECTS_TABLE.value?(value)
          param_name = OBJECTS_TABLE.key(value)
          query_string += "#{param_name},"
        end
      end

      query_string = query_string[0..-2]
    end
  end
end
