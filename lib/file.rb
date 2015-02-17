require 'restful_model'

module Inbox
  class File < RestfulModel

    parameter :size
    parameter :filename
    parameter :content_type
    parameter :is_embedded
    parameter :message_id

    # For uploading the file
    parameter :file

    def inflate(json)
      super
      content_type = json["content-type"] if json["content-type"]
    end

    def save!
      ::RestClient.post(url, {:file => @file}) do |response, request, result|
        json = Inbox.interpret_response(result, response, :expected_class => Object)
        json = json[0] if (json.class == Array)
        inflate(json)
      end
      self
    end

    def download
      RestClient.get(url + '/download')
    end
  end
end

