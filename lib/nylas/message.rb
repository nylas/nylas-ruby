require 'nylas/restful_model'
require 'nylas/file'
require 'nylas/mixins'

module Nylas
  class Message < RestfulModel

    attr_reader :events

    parameter :subject
    parameter :snippet
    parameter :from
    parameter :to
    parameter :reply_to
    parameter :cc
    parameter :bcc
    parameter :date
    parameter :thread_id
    parameter :body
    parameter :unread
    parameter :starred
    parameter :folder
    parameter :labels

    include Nylas::ReadUnreadMethods

    def inflate(json)
      super
      self.to ||= []
      self.cc ||= []
      self.bcc ||= []
      self.labels ||= []
      self.folder ||= nil
      self.events = json["events"] if json["events"]

      # This is a special case --- we receive label data from the API
      # as JSON but we want it to behave like an API object.
      labels.map! do |label_json|
        label = Label.new(@_api)
        label.inflate(label_json)
        label
      end

      unless folder.nil? || !folder.is_a?(Hash)
        self.folder = Folder.new(@_api)
        self.folder.inflate(folder)
        self.folder = folder
      end
    end

    def as_json(options = {})
      hash = {}

      # unread, starred and labels/folder are the only attribute
      # you can modify.
      unless unread.nil?
        hash["unread"] = unread
      end

      unless starred.nil?
        hash["starred"] = starred
      end

      unless labels.nil? || labels.empty?
        hash["label_ids"] = labels.map do |label|
          if !label.respond_to?(:id)
            raise TypeError, "label #{label} does not respond to #id"
          end
          label.id
        end
      end

      if !folder.nil? && !folder.respond_to?(:id)
        raise TypeError, "folder #{folder} does not respond to #id"
      end

      unless folder.nil?
        hash["folder_id"] = folder.id
      end

      hash
    end


    def events?
      !events.nil? && !events.empty?
    end


    def files
      model_state[:files] ||= RestfulModelCollection.new(File, @_api, {:message_id=>id})
    end

    def files?
      !@raw_json['files'].empty?
    end

    def raw
      collection = RestfulModelCollection.new(Message, @_api, {:message_id=> id})
      url = "#{collection.url}/#{id}/"
      @_api.get(url, accept: 'message/rfc822') do |response, _request, result|
        Nylas.interpret_response(result, response, raw_response: true)
      end
    end

    def expanded
      @_api.get(url('?view=expanded')) do |response, _request, result|
        json = Nylas.interpret_response(result, response, expected_class: Object)
        expanded_message = Nylas::ExpandedMessage.new(@_api)
        expanded_message.inflate(json)
        expanded_message
      end
    end


    private def events=(events)
      unless events.respond_to?(:map)
        raise TypeError, "unable to iterate over #{events}, events must respond to #map"
      end

      @events = events.map do |event_data|
        next event_data if event_data.respond_to?(:id)
        unless event_data.respond_to?(:key)
          raise TypeError, "unable to cast #{event_data} to an event."
        end
        event = Nylas::Event.new(@_api)
        event.inflate(event_data)
        event
      end
    end
  end
end
