# frozen_string_literal: true

module Nylas::V2
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
    attribute :secondary_address, :string
  end
end
