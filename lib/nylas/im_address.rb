module Nylas
  class IMAddress
    include Model::Attributable
    attribute :type, :string
    attribute :im_address, :string
  end

  class IMAddressType < Types::HashType
    casts_to IMAddress
  end

  Types.registry[:im_address] = IMAddressType.new
end

