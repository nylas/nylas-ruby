require 'restful_model'

module Inbox
  class Draft < Message

    parameter :thread_id
    parameter :version
    parameter :reply_to_message_id
    parameter :file_ids

    def attach(file)
      file.save! unless file.id
      @file_ids ||= []
      @file_ids.push(file.id)
    end

    def as_json(options = {})
      # FIXME @karim: this is a bit of a hack --- Draft inherits Message
      # was okay until we overrode Message#as_json to allow updating folders/labels.
      # This broke draft sending, which relies on RestfulModel::as_json to work.
      grandparent = self.class.superclass.superclass
      meth = grandparent.instance_method(:as_json)
      meth.bind(self).call
    end

    def send!
      url = @_api.url_for_path("/send")
      if @id
        data = {:draft_id => @id, :version => @version}
      else
        data = as_json()
      end

      ::RestClient.post(url, data.to_json, :content_type => :json) do |response, request, result|

        # This is mostly lifted from Inbox#interpret_response. We're not using the original function
        # because we need to pass an additional error message to the Exception constructor.
        Inbox.interpret_http_status(result)
        json = JSON.parse(response)
        if json.is_a?(Hash) && (json['type'] == 'api_error' or json['type'] == 'invalid_request_error')
          exc = Inbox.http_code_to_exception(result.code.to_i)
          exc_type = json['type']
          exc_message = json['message']
          exc_server_error = json['server_error']
          raise exc.new(exc_type, exc_message, server_error=exc_server_error)
        end
        raise UnexpectedResponse.new(result.msg) if result.is_a?(Net::HTTPClientError)

        self.inflate(json)
      end

      self
    end

  end
end
