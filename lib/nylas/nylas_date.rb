module Nylas
  class NylasDate
    extend Forwardable
    def_delegators :date, :===, :==, :<=>, :eql?, :equal?

    include Model::Attributable
    attribute :object, :string
    attribute :date, :date
  end

  class NylasDateType < Types::HashType
    casts_to NylasDate
    def cast(value)
      value.is_a?(String) ? super({ object: "date", date: value}) : super
    end
  end

  Types.registry[:nylas_date] = NylasDateType.new
end
