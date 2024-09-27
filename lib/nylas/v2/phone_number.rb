# frozen_string_literal: true

module Nylas::V2
  # Structure to represent the Phone Number Schema
  # @see https://docs.nylas.com/reference#contactsid
  class PhoneNumber
    include Model::Attributable
    attribute :type, :string
    attribute :number, :string
  end
end
