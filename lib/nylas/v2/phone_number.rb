module Nylas
  module V2
    class PhoneNumber
      include Model::Attributable
      attribute :type, :string
      attribute :number, :string
    end

    class PhoneNumberType < Types::HashType
      casts_to PhoneNumber
    end

    Types.registry[:phone_number] = PhoneNumberType.new
  end
end

