require 'restful_model'
require 'event'

module Inbox
  class Calendar < RestfulModel

    parameter :name
    parameter :description
    parameter :read_only

    def events
      @events ||= RestfulModelCollection.new(Event, @_api, @namespace_id, {:calendar_id=>@id})
    end

  end
end
