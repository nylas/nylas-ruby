module Nylas
  # Structure to represent the IM Address Schema
  # @see https://docs.nylas.com/reference#contactsid
  class IMAddress
    include Model::Attributable
    attribute :type, :string
    attribute :im_address, :string
  end

  # Serializes, Deserializes between {IMAddress} objects and their JSON representation
  class IMAddressType < Types::HashType
    casts_to IMAddress
  end
end
