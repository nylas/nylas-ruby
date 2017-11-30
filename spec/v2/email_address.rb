module Nylas
  module V2
    class EmailAddress
      include Model::Attributable
      attribute :type, :string
      attribute :email, :string
    end

    class EmailAddressType < ValueType
      def cast(value)
        return value if value.respond_to?(:email) && value.respond_to?(:type)
        return EmailAddress.new(type: nil, email: value) if value.is_a?(String)
        return EmailAddress.new(**value) if value.respond_to?(:key?) && (value.key?(:email) || value.key?(:type))
        raise TypeError, "Unable to cast #{value} to an EmailAddress"
      end

      def serialize(object)
        EmailAddress.new(**value)
      end
    end

    Types.registry[:email_address] = EmailAddressType.new
  end
end

