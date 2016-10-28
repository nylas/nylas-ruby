require 'restful_model'
require 'time_attr_accessor'
require 'mixins'

module Nylas
  class Thread < RestfulModel
    extend TimeAttrAccessor

    parameter :subject
    parameter :participants
    parameter :snippet
    parameter :message_ids
    parameter :draft_ids
    parameter :labels
    parameter :folder
    parameter :starred
    parameter :unread
    parameter :has_attachments
    time_attr_accessor :last_message_timestamp
    time_attr_accessor :first_message_timestamp

    include ReadUnreadMethods

    def inflate(json)
      super
      @labels ||= []
      @folder ||= nil

      # This is a special case --- we receive label data from the API
      # as JSON but we want it to behave like an API object.
      @labels.map! do |label_json|
       label = Label.new(@_api)
       label.inflate(label_json)
       label
      end

      if not folder.nil? and folder.is_a?(Hash)
       folder = Folder.new(@_api)
       folder.inflate(@folder)
       @folder = folder
      end
    end

    def messages
      @messages ||= RestfulModelCollection.new(Message, @_api, {:thread_id=>@id})
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, @_api, {:thread_id=>@id})
    end

    def as_json(options = {})
      hash = {}

      if not @unread.nil?
        hash["unread"] = @unread
      end

      if not @starred.nil?
        hash["starred"] = @starred
      end

      if not @labels.nil? and @labels != []
        hash["label_ids"] = @labels.map do |label|
          label.id
        end
      end

      if not @folder.nil?
        hash["folder_id"] = @folder.id
      end

      hash
    end

  end
end
