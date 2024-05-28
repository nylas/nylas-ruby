# frozen_string_literal: true

module NylasV2Helpers
  def api_key
    "api-key-123"
  end

  def api_uri
    "https://test.api.nylas.com"
  end

  def timeout
    60
  end

  def client
    NylasV2::Client.new(api_key: api_key, api_uri: api_uri, timeout: timeout)
  end
end
