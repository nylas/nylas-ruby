require 'restful_model'

module Inbox
  class File < RestfulModel

    attr_accessor :size
    attr_accessor :filename
    attr_accessor :content_type
    attr_accessor :is_embedded
    attr_accessor :message

    # For uploading the file
    attr_accessor :file

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

  end
end

