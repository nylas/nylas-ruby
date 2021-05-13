# frozen_string_literal: true

module Nylas
  # Ruby object to represent a single change. Used both when receiving a webhook, as well as the deltas API.
  # @see https://docs.nylas.com/reference#receiving-notifications
  # @see https://docs.nylas.com/reference#deltas
  class Delta
    include Model::Attributable

    attribute :id, :string
    attribute :type, :string
    attribute :object, :string
    attribute :event, :string
    attribute :cursor, :string
    attribute :namespace_id, :string
    attribute :account_id, :string

    attribute :date, :unix_timestamp
    attribute :metadata, :hash
    attribute :object_attributes, :hash

    def model
      return nil if object.nil?

      @model ||= Types.registry[object.to_sym].cast(object_attributes_with_ids)
    end

    private

    def object_attributes_with_ids
      (object_attributes || {}).merge(id: id, account_id: account_id)
    end
  end

  # Casts Delta data from either a webhook or a delta stream to a Delta
  class DeltaType < Types::ModelType
    def initialize
      super(model: Delta)
    end

    def cast(data)
      data = if data.key?(:object_data)
               object_data = data.delete(:object_data)
               data.merge(object_data)
             else
               data
             end

      data = data.merge(data[:attributes]) if data[:attributes]
      data[:object_attributes] = data.delete(:attributes)
      super(**data)
    end
  end
end
