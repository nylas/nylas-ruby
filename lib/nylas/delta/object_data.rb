module Nylas
  class Delta
    # Abstraction to allow Delta objects to include any kind of data
    class ObjectData
      include Model::Attributable
      attribute :id, :string
      attribute :namespace_id, :string
      attribute :account_id, :string
      attribute :object, :string
      attribute :metadata, :hash
      attribute :object_attributes, :hash

      def instance
        @instance ||= Types.registry[object.to_sym].cast(object_attributes_with_ids)
      end

      def object_attributes_with_ids
        (object_attributes || {}).merge(id: id, account_id: account_id)
      end
    end

    # Casts Webhook data to the ObjectData and populates the necessary data for an instance
    class ObjectDataType < Types::ModelType
      def initialize
        super(model: ObjectData)
      end

      def cast(data)
        data[:object_attributes] = data.delete(:attributes)
        super(data)
      end
    end
  end
end
