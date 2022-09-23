# frozen_string_literal: true

module Nylas
  # Structure to represent all the Nylas time types.
  # @see https://docs.nylas.com/reference#section-time
  class When
    extend Forwardable

    include Model::Attributable

    attribute :object, :string, read_only: true

    # when object == 'date'
    attribute :date, :date

    # when object == 'datespan'
    attribute :start_date, :date
    attribute :end_date, :date

    # when object == 'time'
    attribute :time, :unix_timestamp
    attribute :timezone, :string

    # when object == 'timespan'
    attribute :start_time, :unix_timestamp
    attribute :end_time, :unix_timestamp
    attribute :start_timezone, :string
    attribute :end_timezone, :string

    def_delegators :range, :cover?

    def as_timespan
      return unless object == "timespan"

      Timespan.new(object: object, start_time: start_time, end_time: end_time)
    end

    def range
      case object
      when "timespan"
        Range.new(start_time, end_time)
      when "datespan"
        Range.new(start_date, end_date)
      when "date"
        Range.new(date, date)
      when "time"
        Range.new(time, time)
      end
    end
  end
end
