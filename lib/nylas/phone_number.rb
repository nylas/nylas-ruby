module Nylas
  # Structure to represent the Phone Number Schema
  # @see https://docs.nylas.com/reference#contactsid
  class PhoneNumber
    include Model::Attributable
    attribute :type, :string
    attribute :number, :string
  end

  # Serializes, Deserializes between {PhoneNumber} objects and a {Hash}
  class PhoneNumberType < Types::HashType
    casts_to PhoneNumber
  end
end
Nylas::Types.registry[:phone_number] = PhoneNumberType.new
