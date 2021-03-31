# frozen_string_literal: true

module Nylas
  # The constraints a particular GET request will include in their query params
  class Constraints
    attr_accessor :where, :limit, :offset, :view, :per_page, :accept

    def initialize(where: {}, limit: nil, offset: 0, view: nil, per_page: 100, accept: "application/json")
      self.where = where
      self.limit = limit
      self.offset = offset
      self.view = view
      self.per_page = per_page
      self.accept = accept
    end

    def merge(where: {}, limit: nil, offset: nil, view: nil, per_page: nil, accept: nil)
      Constraints.new(where: self.where.merge(where),
                      limit: limit || self.limit,
                      per_page: per_page || self.per_page,
                      offset: offset || self.offset,
                      view: view || self.view,
                      accept: accept || self.accept)
    end

    def next_page
      merge(offset: offset + per_page)
    end

    def to_query
      query = where.each_with_object({}) do |(name, value), result|
        result[name] = value
      end
      query[:limit] = limit_for_query
      query[:offset] = offset unless offset.nil?
      query[:view] = view unless view.nil?
      query
    end

    def to_headers
      accept == "application/json" ? {} : { "Accept" => accept, "Content-types" => accept }
    end

    def limit_for_query
      !limit.nil? && limit < per_page ? limit : per_page
    end

    def self.from_constraints(constraints = Constraints.new)
      return constraints if constraints.is_a?(Constraints)
      return new(**constraints) if constraints.respond_to?(:key?)
      return new if constraints.nil?

      raise TypeError, "passed in constraints #{constraints} cannot be cast to a set of constraints"
    end
  end
end
