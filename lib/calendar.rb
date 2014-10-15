require 'restful_model'
require 'event'

module Inbox
  class Calendar < RestfulModel

    parameter :name
    parameter :description
    parameter :event_ids

    def events
      @events ||= RestfulModelCollection.new(Event, @_api, @namespace, {:calendar_id=>@id})
    end

  end
end