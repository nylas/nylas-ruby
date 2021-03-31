# frozen_string_literal: true

module Nylas
  # Allows sending of email with nylas from an rfc822 compatible string
  class RawMessage
    attr_accessor :api, :mime_compatible_string

    def initialize(mime_compatible_string, api:)
      self.api = api
      self.mime_compatible_string = mime_compatible_string
    end

    def send!
      Message.new(api.execute(method: :post, path: "/send", payload: mime_compatible_string,
                              headers: { "Content-type" => "message/rfc822" }).merge(api: api))
    end
  end
end
