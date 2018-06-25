module Nylas
  # Used to create a hash-like structure which defaults to raising an exception in the event the key to
  # retrieve does not exist.
  class Registry
    # Used to indicate an attempt to retrieve something not yet registered in a registry
    # Includes the list of keys in the registry for debug purposes.
    class MissingKeyError < Error
      def initialize(key, keys)
        super("key #{key} not in #{keys}")
      end
    end
    attr_accessor :registry_data

    extend Forwardable
    def_delegators :registry_data, :keys, :each, :reduce, :key?

    def initialize(initial_data = {})
      self.registry_data = initial_data.each.each_with_object({}) do |(key, value), registry|
        registry[key] = value
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
