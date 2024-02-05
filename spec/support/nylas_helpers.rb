# frozen_string_literal: true

module NylasHelpers
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
    Nylas::Client.new(api_key: api_key, api_uri: api_uri, timeout: timeout)
  end
end
