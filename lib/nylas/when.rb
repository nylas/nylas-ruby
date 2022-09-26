# frozen_string_literal: true

module Nylas
  require "tzinfo"

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
    # Timezone must be set to a valid IANA database timezone name
    attribute :timezone, :string

    # when object == 'timespan'
    attribute :start_time, :unix_timestamp
    attribute :end_time, :unix_timestamp
    # Both timezone fields must be set to a valid IANA database timezone name
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

    # Validates the When object
    # @return [Boolean] True if the When is valid
    # @raise [ArgumentError] If any of the timezone fields are not valid IANA database names
    def valid?
      validate_timezone(timezone) if timezone
      validate_timezone(start_timezone) if start_timezone
      validate_timezone(end_timezone) if end_timezone

      true
    end

    private

    def validate_timezone(timezone_var)
      return if TZInfo::Timezone.all_identifiers.include?(timezone_var)

      raise ArgumentError,
            format("The timezone provided (%s) is not a valid IANA timezone database name", timezone_var)
    end
  end
end
