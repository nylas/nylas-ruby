module Nylas
  class HashToQuery
    attr_accessor :hash
    def initialize(hash)
      self.hash = hash
    end

    def to_s
      hash.reduce("") do |query, (key, value)|
        next query if value.nil?
        pair = "#{key}=#{URI.escape(value.to_s)}"
        query.empty? ? "#{query}#{pair}" : "#{query}&#{pair}"
      end
    end
  end
end
