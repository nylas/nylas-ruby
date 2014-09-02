require 'restful_model'
require 'event'

module Inbox
  class Calendar < RestfulModel

    attr_accessor :name
    attr_accessor :description
    attr_accessor :event_ids

    def events
      @events ||= RestfulModelCollection.new(Event, @_api, @namespace, {:calendar_id=>@id})
    end

  end
end