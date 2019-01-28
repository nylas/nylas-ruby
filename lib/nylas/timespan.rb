module Nylas
  # Structure to represent a Nylas Timespan.
  # @see https://docs.nylas.com/reference#section-timespan
  class Timespan
    extend Forwardable

    include Model::Attributable
    attribute :object, :string
    attribute :start_time, :unix_timestamp
    attribute :end_time, :unix_timestamp
    attribute :time, :unix_timestamp
    attribute :date, :string
    attribute :start_date, :string
    attribute :end_date, :string

    def_delegators :range, :cover?

    def range
      @range ||= Range.new(start_time, end_time)
    end
  end
end
