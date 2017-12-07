module Nylas
  class EmailAddress
    include Model::Attributable
    attribute :type, :string
    attribute :email, :string
  end

  class EmailAddressType < Types::HashType
    casts_to EmailAddress
  end

  Types.registry[:email_address] = EmailAddressType.new
end

