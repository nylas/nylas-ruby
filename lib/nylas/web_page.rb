module Nylas
  # Structure to represent the Web Page Schema
  # @see https://docs.nylas.com/reference#contactsid
  class WebPage
    include Model::Attributable
    attribute :type, :string
    attribute :url, :string
  end

  # Serializes, Deserializes between {WebPage} objects and a {Hash}
  class WebPageType < Types::HashType
    casts_to WebPage
  end

  Types.registry[:web_page] = WebPageType.new
end
