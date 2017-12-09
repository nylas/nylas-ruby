module Nylas
  # Structure to represent Nylas's more complex Date Schema
  # @see https://docs.nylas.com/reference#contactsid
  class NylasDate
    extend Forwardable
    def_delegators :date, :===, :==, :<=>, :eql?, :equal?

    include Model::Attributable
    attribute :object, :string
    attribute :date, :date
  end

  # Serializes, Deserializes between {NylasDate} objects and a {Hash}
  class NylasDateType < Types::HashType
    casts_to NylasDate
    def cast(value)
      value.is_a?(String) ? super({ object: "date", date: value }) : super
    end
  end
end
Nylas::Types.registry[:nylas_date] = NylasDateType.new
