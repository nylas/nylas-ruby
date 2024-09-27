# frozen_string_literal: true

module Nylas::V2
  # Structure to represent a the Neural Categorizer object.
  # @see https://developer.nylas.com/docs/intelligence/categorizer/#categorize-message-response
  class NeuralCategorizer < Message
    include Model
    self.resources_path = "/neural/categorize"
    self.listable = true

    attribute :categorizer, :categorize
    # Overrides Message's label attribute as currently categorize returns
    # list of strings for labels instead of label object types
    has_n_of_attribute :labels, :string

    inherit_attributes

    def recategorize(category)
      body = { message_id: id, category: category }
      api.execute(
        method: :post,
        path: "#{resources_path}/feedback",
        payload: JSON.dump(body)
      )
      list = api.neural.categorize([id])
      list[0]
    end
  end
end
