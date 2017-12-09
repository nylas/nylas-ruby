module Nylas
  class Registry
    class MissingKeyError < Error
      def initialize(key, keys)
        super("key #{key} not in #{keys}")
      end
    end
    attr_accessor :registry_data

    extend Forwardable
    def_delegators :registry_data, :keys, :each, :reduce

    def initialize(initial_data = {})
      self.registry_data = initial_data.each.reduce({}) do |registry, (key, value)|
        registry[key] = value
        registry
      end
    end

    def [](key)
      registry_data.fetch(key)
    rescue KeyError
      raise MissingKeyError.new(key, keys)
    end

    def []=(key, value)
      registry_data[key] = value
    end

    def to_h
      registry_data
    end
  end
end
