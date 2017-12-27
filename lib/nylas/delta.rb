require_relative "delta/object_data"
module Nylas
  # Ruby object to represent a single change. Used both when receiving a webhook, as well as the deltas API.
  # @see https://docs.nylas.com/reference#receiving-notifications
  # @see https://docs.nylas.com/reference#deltas
  class Delta
    include Model::Attributable
    attribute :date, :unix_timestamp
    attribute :type, :string
    attribute :object, :string
    attribute :object_data, :delta_object_data

    extend Forwardable
    def_delegators :object_data, :id, :namespace_id, :account_id, :metadata, :object_attributes, :instance
  end
end
