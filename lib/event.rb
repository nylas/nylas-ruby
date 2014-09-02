require 'restful_model'

module Inbox
  class Event < RestfulModel

    attr_accessor :title
    attr_accessor :description
    attr_accessor :location
    attr_accessor :read_only
    attr_accessor :participants
    attr_accessor :when

  end
end