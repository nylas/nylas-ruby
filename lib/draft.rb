require 'restful_model'

module Inbox
  class Draft < Message

    attr_accessor :thread_id
    attr_accessor :state

    def attach(file)
      file.save! unless file.id
      @file_ids.push(file.id)
    end

    def send!
      save! unless @id

      url = @_api.url_for_path("/n/#{@namespace_id}/send")
      data = {:draft_id => @id}

      ::RestClient.post(url, data.to_json, :content_type => :json) do |response, request, result|
        Inbox.interpret_response(result, response, :expected_class => Object)
      end

      self
    end

  end
end