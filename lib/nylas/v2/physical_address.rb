module Nylas
  module V2
    class PhysicalAddress
      include Model::Attributable
      attribute :format, :string
      attribute :type, :string
      attribute :street_address, :string
      attribute :postal_code, :string
      attribute :state, :string
      attribute :country, :string
    end

    class PhysicalAddressType < Types::HashType
      casts_to PhysicalAddress
    end

    Types.registry[:physical_address] = PhysicalAddressType.new
  end
end

