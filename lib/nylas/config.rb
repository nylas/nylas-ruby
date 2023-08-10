# frozen_string_literal: true

module Nylas
  # Configuration options for the Nylas Ruby SDK.
  module Config
    # The configuration options for the different supported regions.
    REGION_CONFIG = {
      us: {
        nylas_api_url: "https://api.us.nylas.com"
      },
      eu: {
        nylas_api_url: "https://api.eu.nylas.com"
      }
    }.freeze

    # The default API endpoint for the Nylas API.
    DEFAULT_REGION_URL = REGION_CONFIG[:us][:nylas_api_url]
  end
end
