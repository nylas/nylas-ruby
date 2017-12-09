module Nylas
  class WebPage
    include Model::Attributable
    attribute :type, :string
    attribute :url, :string
  end

  class WebPageType < Types::HashType
    casts_to WebPage
  end

  Types.registry[:web_page] = WebPageType.new
end

