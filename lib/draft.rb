require 'restful_model'

module Nylas
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
        response = Nylas.interpret_response(result, response, {:expected_class => Object})
        self.inflate(response)
      end

      self
    end

  end
end
