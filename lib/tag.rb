require 'restful_model'

module Inbox
  class Tag < RestfulModel

    attr_accessor :name
    attr_accessor :namespace

  end
end