require 'nylas/restful_model'

module Nylas
  class Event < RestfulModel

    parameter :title
    parameter :description
    parameter :location
    parameter :read_only
    parameter :participants
    parameter :when
    parameter :calendar_id
    parameter :namespace_id
    parameter :recurrence
    parameter :status
    parameter :master_event_id
    parameter :original_start_time

    def as_json(options = {})
      hash = super(options)

      # Delete nil values from the hash
      hash.delete_if { |key, value| value.nil? }

      # The API doesn't like to receive: "object": "timespan" in the when block.
      if hash.has_key?('when') and hash['when'].has_key?('object')
        hash['when'].delete('object')
      end

      return hash
    end

    def rsvp!(status, comment)
      url = @_api.url_for_path("/send-rsvp")
      data = {:event_id => @id, :status => status, :comment => comment}

      @_api.post(url: url, payload: data.to_json, headers: { content_type: :json }) do |response, _request, result|
        json = Nylas.interpret_response(result, response, expected_class: Object)
        self.inflate(json)
      end

      self
    end
  end
end
