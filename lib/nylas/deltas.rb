module Nylas
  # Ruby object to represent a collection of changes. Used both when receiving a webhook, as well as the
  # deltas API.
  # @see https://docs.nylas.com/reference#receiving-notifications
  # @see https://docs.nylas.com/reference#deltas
  class Deltas
    include Model
    self.resources_path = "/delta"
    has_n_of_attribute :deltas, :delta
    attribute :cursor_start, :string
    attribute :cursor_end, :string

    extend Forwardable
    def_delegators :deltas, :length, :each, :map, :first
  end
end
