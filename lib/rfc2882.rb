require 'base64'
require 'restful_model'

module Inbox
  class Rfc2822 < RestfulModel

    parameter :rfc2822

    def inflate(json)
      super
      # The 'rfc2822' attribute is a base64-encoded string. Decode it.
      @rfc2822 = Base64.decode64(@rfc2822) if json.has_key?('rfc2822')
    end
  end
end
