module Nylas
  # Provides a way to access data in a hash consistently by casting keys to an
  # expected type.
  #
  # @note Could be replaced by HashWithIndifferentAccess if we decided to bring
  #       in ActiveSupport as a runtime dependency.
  class HashWithNormalizedKeys
    extend Forwardable
    def_delegators :@data, *(Hash.instance_methods - [:key?, :has_key?, :[], :[]=])

    # @param data [Hash] Initial data
    # @param normalize_keys_with [Proc] optional function to cast keys, defaults to `key.to_s.to_sym`
    def initialize(data, normalize_keys_with: ->(key) { key.to_s.to_sym })
      @normalize_keys_with = normalize_keys_with
      @data = {}
      data.keys.each do |key|
        self[key] = data[key]
      end
    end

    def key?(key)
      @data.key?(normalize_key(key))
    end

    alias_method :has_key?, :key?


    # Sets the value in the data hash but casts the key first
    def []=(key, value)
      data[normalize_key(key)] = value
    end

    # Retrieves a value from the data hash from the cast key first
    def [](key)
      data[normalize_key(key)]
    end

    private

    attr_accessor :data, :normalize_keys_with

    def normalize_key(key)
      normalize_keys_with.call(key)
    end
  end
end
