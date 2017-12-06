require 'nylas/restful_model'

module Nylas
  class Draft < Message

    parameter :thread_id
    parameter :version
    parameter :reply_to_message_id
    parameter :file_ids
    parameter :tracking

    def attach(file)
      file.save! unless file.id
      self.file_ids ||= []
      self.file_ids.push(file.id)
    end

    def as_json(options = {})
      model_state.as_json(options)
    end

    def send!
      url = @_api.url_for_path("/send")
      if id
        data = {:draft_id => id, :version => version}
      else
        data = as_json()
      end

      @_api.post(url, data.to_json, :content_type => :json) do |response, request, result|
        response = Nylas.interpret_response(result, response, expected_class: Object)
        self.inflate(response)
      end

      self
    end

    def destroy
      payload = { version: version }.to_json
      @_api.delete(url, payload) do |response, _request, result|
        Nylas.interpret_response(result, response, raw_response: true)
      end
    end
  end
end
