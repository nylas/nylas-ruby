module Nylas
  # Structure to represent a the Neural Optical Character Recognition object.
  # @see https://developer.nylas.com/docs/intelligence/optical-charecter-recognition/#ocr-response
  class Categorize
    include Model::Attributable

    attribute :category, :string
    attribute :categorized_at, :unix_timestamp
    attribute :model_version, :string
    has_n_of_attribute :subcategories, :string
  end
end


