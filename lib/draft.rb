require 'restful_model'

module Inbox
  class Draft < Message

    attr_accessor :reply_to_thread
    attr_accessor :state

    def send!
      send_url = @_api.url_for_path("/n/#{@namespace}/send")
      data = as_json()
      ::RestClient.post(send_url, data) do |response, request, result|
        Inbox.interpret_response(result, response, :expected_class => Object)
      end
      self
    end

  end
end