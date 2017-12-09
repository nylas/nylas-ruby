module Nylas
  # Structure to represent the Physical Address schema
  # @see https://docs.nylas.com/reference#contactsid
  class PhysicalAddress
    include Model::Attributable
    attribute :format, :string
    attribute :type, :string
    attribute :street_address, :string
    attribute :postal_code, :string
    attribute :state, :string
    attribute :city, :string
    attribute :country, :string
  end

  # Serializes, Deserializes between {PhysicalAddress} objects and a {Hash}
  class PhysicalAddressType < Types::HashType
    casts_to PhysicalAddress
  end
end
Nylas::Types.registry[:physical_address] = PhysicalAddressType.new
