require_relative 'restful_model'
require_relative 'event'

module Nylas
  module V1
    class Calendar < RestfulModel

      parameter :name
      parameter :description
      parameter :read_only

      def events
        @events ||= RestfulModelCollection.new(Event, @_api, {:calendar_id=>@id})
      end

    end
  end
end
