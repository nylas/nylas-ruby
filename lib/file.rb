require 'restful_model'

module Inbox
  class File < RestfulModel

    attr_accessor :size
    attr_accessor :filename
    attr_accessor :content_type
    attr_accessor :is_embedded
    attr_accessor :message

    def inflate(json)
      super
      content_type = json["content-type"] if json["content-type"]
    end

  end
end

