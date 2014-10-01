require 'restful_model'

module Inbox
  class Event < RestfulModel

    parameter :title
    parameter :description
    parameter :location
    parameter :read_only
    parameter :participants
    parameter :when

  end
end