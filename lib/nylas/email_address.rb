module Nylas
  # Structure to represent the Email Address Schema
  # @see https://docs.nylas.com/reference#contactsid
  class EmailAddress
    include Model::Attributable
    attribute :type, :string
    attribute :email, :string
  end

  # Serializes, Deserializes between {EmailAddress} objects and a {Hash}
  class EmailAddressType < Types::HashType
    casts_to EmailAddress
  end
end

Nylas::Types.registry[:email_address] = EmailAddressType.new
