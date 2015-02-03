require 'restful_model'

module Inbox
  class Draft < Message

    parameter :thread_id
    parameter :version

    def attach(file)
      file.save! unless file.id
      @file_ids.push(file.id)
    end

    def send!
      url = @_api.url_for_path("/n/#{@namespace_id}/send")
      if @id
        data = {:draft_id => @id, :version => @version}
      else
        data = as_json()
      end

      ::RestClient.post(url, data.to_json, :content_type => :json) do |response, request, result|
        json = Inbox.interpret_response(result, response, :expected_class => Object)
        self.inflate(json)
      end

      self
    end

  end
end
