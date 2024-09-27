# frozen_string_literal: true

module Nylas::V2
  # Ruby representation of a Nylas Room Resource object
  # @see https://developer.nylas.com/docs/api/#tag--Room-Resources
  class RoomResource
    include Model
    self.resources_path = "/resources"
    self.listable = true

    attribute :object, :string, read_only: true
    attribute :email, :string, read_only: true
    attribute :name, :string, read_only: true
    attribute :capacity, :string, read_only: true
    attribute :building, :string, read_only: true
    attribute :floor_name, :string, read_only: true
    attribute :floor_number, :string, read_only: true
  end
end
